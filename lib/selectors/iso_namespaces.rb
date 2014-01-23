# Helper class to provide default namespaces for XML document parsing.
class IsoNamespaces
  def self.get_namespaces(doc)
    ISO_NAMESPACES.merge(doc.namespaces)
  end

  private

  ISO_NAMESPACES = {
    'gmd' => 'http://www.isotc211.org/2005/gmd',
    'gco' => 'http://www.isotc211.org/2005/gco',
    'gml' => 'http://www.opengis.net/gml/3.2',
    'gmi' => 'http://www.isotc211.org/2005/gmi'
  }
end
