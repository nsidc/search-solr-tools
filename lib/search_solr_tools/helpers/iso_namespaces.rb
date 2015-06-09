module SearchSolrTools
  module Helpers
    # Helper class to provide default namespaces for XML document parsing.
    class IsoNamespaces
      def self.namespaces(doc = nil)
        ISO_NAMESPACES.merge(doc.nil? ? {} : doc.namespaces)
      end

      ISO_NAMESPACES = {
        'csw' => 'http://www.opengis.net/cat/csw/2.0.2',
        'gmd' => 'http://www.isotc211.org/2005/gmd',
        'gco' => 'http://www.isotc211.org/2005/gco',
        'gml' => 'http://www.opengis.net/gml/3.2',
        'gmi' => 'http://www.isotc211.org/2005/gmi',
        'gmx' => 'http://www.isotc211.org/2005/gmx',
        'gsr' => 'http://www.isotc211.org/2005/gsr',
        'gss' => 'http://www.isotc211.org/2005/gss',
        'gts' => 'http://www.isotc211.org/2005/gts',
        'srv' => 'http://www.isotc211.org/2005/srv',
        'xlink' => 'http://www.w3.org/1999/xlink',
        'xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'oai' => 'http://www.openarchives.org/OAI/2.0/',
        'dif' => 'http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/',
        'atom' => 'http://www.w3.org/2005/Atom',
        'dc' => 'http://purl.org/dc/elements/1.1/',
        'georss' => 'http://www.georss.org/georss'
      }
    end
  end
end
