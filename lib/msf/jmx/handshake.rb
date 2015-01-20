# -*- coding: binary -*-

module Msf
  module Jmx
    module Handshake
      def handshake_stream(id)
        block_data = Rex::Java::Serialization::Model::BlockData.new(nil, "#{id}\xff\xff\xff\xff\xf0\xe0\x74\xea\xad\x0c\xae\xa8")

        stream = Rex::Java::Serialization::Model::Stream.new
        stream.contents << block_data

        if jmx_role
          username = jmx_role
          password = jmx_password || ''

          stream.contents << auth_array_stream(username, password)
        else
          stream.contents << Rex::Java::Serialization::Model::NullReference.new
        end

        stream
      end

      def auth_array_stream(username, password)
        builder = Rex::Java::Serialization::Builder.new

        auth_array = builder.new_array(
          name: '[Ljava.lang.String;',
          serial: 0xadd256e7e91d7b47,
          values_type: 'java.lang.String;',
          values: [
            Rex::Java::Serialization::Model::Utf.new(nil, username),
            Rex::Java::Serialization::Model::Utf.new(nil, password)
          ]
        )

        auth_array
      end

      def extract_rmi_connection_stub(block_data)
        data_io = StringIO.new(block_data.contents)

        ref = extract_string(data_io)
        return nil unless ref && ref == 'UnicastRef'

        address = extract_string(data_io)
        return nil unless address

        port = extract_int(data_io)
        return nil unless port

        id = data_io.read

        { address: address, port: port, :id => id }
      end
    end
  end
end
