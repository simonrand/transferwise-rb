require 'spec_helper'

describe Transferwise::Request do
  describe '.api_url' do
    subject(:api_url) { Transferwise::Request.api_url }

    after do
      Transferwise.remove_instance_variable :@api_base if Transferwise.instance_variable_defined? :@api_base
    end

    it { is_expected.to eq 'https://api.sandbox.transferwise.tech' }

    context 'specifying a URL' do
      subject(:api_url) { Transferwise::Request.api_url('/v1/foo/bar') }

      it { is_expected.to eq 'https://api.sandbox.transferwise.tech/v1/foo/bar' }
    end

    context 'live mode' do
      before { expect(Transferwise).to receive(:mode).and_return 'live' }

      it { is_expected.to eq 'https://api.transferwise.com' }
    end
  end

  describe '.request' do
    let(:access_token) { SecureRandom.uuid }

    context 'GET method' do
      it 'calls to API for requested URL' do
        stub_authed_request(:get, '/v1/widgets', access_token).
          to_return(body: '[{"id":1234,"name":"Spoon"}]')

        response = Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
        expect(response).to eq [{ 'id' => 1234, 'name' => 'Spoon' }]
      end

      it 'concatenates params on URL' do
        stub_authed_request(:get, '/v1/widgets?filter=wood', access_token).
          to_return(body: '[{"id":5432,"name":"Chair"}]')

        response =
          Transferwise::Request.request(
            :get,
            '/v1/widgets',
            { filter: 'wood'},
            { access_token: access_token }
          )
        expect(response).to eq [{ 'id' => 5432, 'name' => 'Chair' }]
      end

      context 'access_token configured on Transferwise' do
        before { allow(Transferwise).to receive(:access_token).and_return 'fallback-token' }

        it 'uses token provided in headers' do
          stub_authed_request(:get, '/v1/widgets', access_token).
            to_return(body: '[{"id":2345,"name":"Bird"}]')

          response = Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
          expect(response).to eq [{ 'id' => 2345, 'name' => 'Bird' }]
        end

        it 'falls back to globally configured option' do
          stub_authed_request(:get, '/v1/widgets', 'fallback-token').
            to_return(body: '[{"id":3456,"name":"Hat"}]')

          response = Transferwise::Request.request :get, '/v1/widgets'
          expect(response).to eq [{ 'id' => 3456, 'name' => 'Hat' }]
        end
      end

      context 'response is invalid JSON' do
        it 'raises ParseError' do
          stub_authed_request(:get, '/v1/widgets', access_token).
            to_return(body: 'invalid body')

          expect do
            Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
          end.to(
            raise_error(
              Transferwise::ParseError,
              'Not able to parse because of invalid response object from API: "invalid body"' \
              ' (HTTP response code was 200)'
            )
          )
        end
      end

      context 'response is a 400 bad request' do
        it 'raises InvalidRequestError' do
          stub_authed_request(:get, '/v1/widgets', access_token).
            to_return(body: '{"error":"That was bad, m\'kay"}', status: 400)

          expect do
            Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
          end.to raise_error Transferwise::InvalidRequestError, "That was bad, m'kay"
        end

        it 'handles multiple errors returned' do
          stub_authed_request(:get, '/v1/widgets', access_token).
            to_return(body: '{"errors":[{"message":"Error 1"},{"message":"Error 2"}]}', status: 400)

          expect do
            Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
          end.to raise_error Transferwise::InvalidRequestError, 'Error 1, Error 2'
        end
      end

      context 'response is a 401 unauthorized' do
        it 'raises AuthenticationError' do
          stub_authed_request(:get, '/v1/widgets', access_token).
            to_return(body: '{"error":"No access for you"}', status: 401)

          expect do
            Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
          end.to raise_error Transferwise::AuthenticationError, 'No access for you'
        end
      end

      context 'response is a 404 not found' do
        it 'raises InvalidRequestError' do
          stub_authed_request(:get, '/v1/widgets', access_token).
            to_return(body: '{"error":"No comprendo"}', status: 404)

          expect do
            Transferwise::Request.request :get, '/v1/widgets', {}, { access_token: access_token }
          end.to raise_error Transferwise::InvalidRequestError, 'No comprendo'
        end
      end
    end

    context 'POST method' do
      it 'calls to API for requested URL' do
        stub_authed_request(:post, '/v1/widgets', access_token).
          with(body: '{}').
          to_return(body: '[{"id":8475,"name":"Spinner"}]')

        response = Transferwise::Request.request :post, '/v1/widgets', {}, { access_token: access_token }
        expect(response).to eq [{ 'id' => 8475, 'name' => 'Spinner' }]
      end

      it 'passes through parameters in the POST body' do
        stub_authed_request(:post, '/v1/widgets', access_token).
          with(body: '{"size":"large"}').
          to_return(body: '[{"id":2938,"name":"Pen"}]')

        response =
          Transferwise::Request.request(
            :post,
            '/v1/widgets',
            { size: 'large' },
            { access_token: access_token }
          )
        expect(response).to eq [{ 'id' => 2938, 'name' => 'Pen' }]
      end
    end
  end
end
