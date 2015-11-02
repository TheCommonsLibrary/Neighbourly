require_relative 'spec_helper'

describe 'main page' do
	describe '/' do
	    it 'returns OK' do
	      get '/'
	      expect(last_response).to be_ok()
	    end
	end
end
