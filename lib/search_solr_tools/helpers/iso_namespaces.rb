module SearchSolrTools
  module Helpers
    # Helper class to provide default namespaces for XML document parsing.
    class IsoNamespaces
      def self.namespaces(doc = nil)
        ISO_NAMESPACES.merge(doc.nil? ? {} : doc.namespaces)
      end

      ISO_NAMESPACES = {
        'atom'   => 'http://www.w3.org/2005/Atom',
        'csw'    => 'http://www.opengis.net/cat/csw/2.0.2',
        'dc'     => 'http://purl.org/dc/elements/1.1/',
        'dif'    => 'http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/',
        'gco'    => 'http://www.isotc211.org/2005/gco',
        'georss' => 'http://www.georss.org/georss',
        'gmd'    => 'http://www.isotc211.org/2005/gmd',
        'gmi'    => 'http://www.isotc211.org/2005/gmi',
        'gml'    => 'http://www.opengis.net/gml/3.2',
        'gmx'    => 'http://www.isotc211.org/2005/gmx',
        'gsr'    => 'http://www.isotc211.org/2005/gsr',
        'gss'    => 'http://www.isotc211.org/2005/gss',
        'gts'    => 'http://www.isotc211.org/2005/gts',
        'oai'    => 'http://www.openarchives.org/OAI/2.0/',
        'rdf'    => 'http://www.w3.org/TR/REC-rdf-syntax',
        'srv'    => 'http://www.isotc211.org/2005/srv',
        'xlink'  => 'http://www.w3.org/1999/xlink',
        'xsi'    => 'http://www.w3.org/2001/XMLSchema-instance'
      }
    end
  end
end
