#---- Extension Nov 2024, RP ----
# Controller for the handling of OAI-PMH requests
# currently restricted to serving 3D model files existing in the public/3dm directory
# and its associated metadata stored in the PostgreSQL database

require 'oai'


module OAI::Provider::Metadata
    class EDM < Format
        def initialize
            @prefix = 'oai_edm'  # Prefix for the EDM format
            @schema = 'https://www.europeana.eu/schemas/edm/EDM.xsd'  # Schema location
            @namespace = 'http://www.europeana.eu/schemas/edm/'
            @element_namespace = 'edm'  # Namespace for XML elements
            @fields = [:dc_creator, :dc_title, :dc_date, :edm_isShownBy, :edm_isShownAt, :edm_object]  # TODO: List all fields provided in monument
        end
    
        def header_specification
            {
                'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
                'xmlns:dcterms' => "http://purl.org/dc/terms/",
                'xmlns:edm' => "http://www.europeana.eu/schemas/edm/",
                'xmlns:ore' => "http://www.openarchives.org/ore/terms/",
                'xmlns:rdf' => "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            }
        end
    end
end


class OaiFilteredActiveRecordWrapper < OAI::Provider::ActiveRecordWrapper
    # overriding find in order to filter monuments returning only records that export a to_oai_edm with non nil result
    def find(selector, options = {})
        # the base class scope queried only by time (from, until)
        base_scope = find_scope(options).where(sql_conditions(options))
        
        # we further narrow down to records that contain a valid (publishable) copyright id
        # (CC-BY-NC 4.0 (copyright_id == 1) or Ubi erat Lupa (copyright_id == 91 and 11)
        allowed_scope = base_scope.joins(:photos)
                            .where(photos: {copyright_id: [1,11,91]})
                            .distinct
        
        # now if we received a resumption token, only extract the paginated next set of the allowed scpe
        return next_set(allowed_scope, options[:resumption_token]) if options[:resumption_token]
        
        # otherwise, if we selected mutiple records
        if selector == :all
            # the scope is too large, paginate using a resumption token, otherwise just return the selected scope
            if @limit && allowed_scope.count > @limit
                select_partial(allowed_scope, OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
            else
                return allowed_scope
            end
        else
            # if there is a single dataset (verb=GetRecord), only extract hte specific id
            record = allowed_scope.where(identifier_field => selector).first
            return (record ) ? record : nil
        end
    end
end


class OaiPmhProvider < OAI::Provider::Base
    repository_name 'Ubi Erat Lupa'
    repository_url 'https://lupa.at/oai'
    admin_email 'paul.bayer@lupa.at'
    record_prefix 'oai:lupa'
    sample_id '456'
    source_model OaiFilteredActiveRecordWrapper.new(Monument, timestamp_field: 'modified', identifier_field: 'id')   

    @formats.delete("oai_dc")   # remove support for oai_dc
    Base.register_format(OAI::Provider::Metadata::EDM.instance)     # we only support oai_edm
end


# app/controllers/oai_pmh_controller.rb
class OaiPmhController < ApplicationController
    
    def index
        # instantiate our provider
        provider = OaiPmhProvider.new

        # Remove controller and action from the options. Rails adds them automatically.
        options = params.delete_if { |k,v| %w{controller action}.include?(k) }
       
        # we don't support sets yet so respond with an error if given
        # options.delete(:set)   # alternative handling: simply remove the set argument at this point (would allow issuing non OAI-conform params though)
        if options[:set]
            render xml: OAI::Provider::Response::Error.new(provider, OAI::SetException.new).to_xml, content_type: 'text/xml'
            return
        end

        # unless we have a resumptionToken, ensure there are time ranges specified. 
        # the oai lib seems to require it in order to avoid some time parsing error in 
        # listrecords, listidentifiers, listmetadataformats, getrecord        
        unless options[:resumptionToken]
            if options[:verb] && (
                    options[:verb].casecmp("listrecords") == 0 ||
                    options[:verb].casecmp("listidentifiers") == 0 ||
                    options[:verb].casecmp("listmetadataformats") == 0 ||
                    options[:verb].casecmp("getrecord") == 0
                )
                options[:from] ||= "2000-01-01"
                options[:until] ||= Date.today.to_s
            end
        end

        # parse options and process request
        response = provider.process_request(options)
        render xml: response, content_type: 'text/xml'            
    end
end
