xml.instruct!
xml.definitions 'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:tns' => 'http://hcp.integration.truekare.jbaysolutions.com/',
                'xmlns:xsd' => 'http://www.w3.org/200/XMLSchema',
                'xmlns:xsi' => 'http://www.w3.org/200/XMLSchema-instance',
                'xmlns' => 'http://schemas.xmlsoap.org/wsdl/',
                'targetNamespace' => 'http://hcp.integration.truekare.jbaysolutions.com/',
                'name' => 'HCProviderService' do

  xml.types do
    xml.tag! "schema", :targetNamespace => @namespace, :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      @map.each do |operation, formats|
        (formats[:in] + formats[:out]).each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end

  @map.each do |operation, formats|
    xml.message :name => "#{operation}" do
      formats[:in].each do |p|
        xml.part wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
    xml.message :name => formats[:response_tag] do
      formats[:out].each do |p|
        xml.part wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
  end

  xml.portType :name => "HCProvider" do
    @map.each do |operation, formats|
      xml.operation :name => operation do
        xml.input :message => "tns:#{operation}"
        xml.output :message => "tns:#{formats[:response_tag]}"
      end
    end
  end

  xml.binding :name => "HCProviderPortBinding", :type => "tns:HCProvider" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.operation :name => operation do
        xml.tag! "soap:operation", :soapAction => operation
        xml.input do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
        xml.output do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
      end
    end
  end

  xml.service :name => "HCProviderService" do
    xml.port :name => "HCProviderPort", :binding => "tns:HCProviderPortBinding" do
      xml.tag! "soap:address", :location => WashOut::Router.url(request, @name)
    end
  end
end
