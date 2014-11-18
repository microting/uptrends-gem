require_relative '../spec_helper'

describe Uptrends::Client do
  let(:username) { ENV['UPTRENDS_USERNAME'] }
  let(:password) { ENV['UPTRENDS_PASSWORD'] }

  describe "Setting up testing" do
    it "should have a username defined in an env varible: UPTRENDS_USERNAME" do
      username.wont_be_nil
    end

    it "should have a password defined in an env varible: UPTRENDS_PASSWORD" do
      password.wont_be_nil
    end
  end

  it "must be an instance of Uptrends::Client" do
    Uptrends::Client.new(username: username, password: password).must_be_instance_of Uptrends::Client
  end

  describe "Initializing with a username and password is required" do
    it "should raise RuntimeError when username is not provided." do
      proc { Uptrends::Client.new(password: password) }.must_raise RuntimeError
    end

    it "should raise excepetion when password is not provided." do
      proc { Uptrends::Client.new(username: username) }.must_raise RuntimeError
    end
  end

  describe "default attributes" do
    it "must include httparty methods" do
      Uptrends::Client.must_include HTTParty
    end

    it "must have the base url set to the Uptrends API endpoint" do
      Uptrends::Client.base_uri.must_equal 'https://api.uptrends.com/v3'
    end

    it "must have the format set to json" do
      Uptrends::Client.format.must_equal :json
    end
  end

  describe "When initializing a new Uptrends::Client with a username and password" do
    let(:uac) { Uptrends::Client.new(username: username, password: password) }

    it "auth[:username] should match the username provided" do
      uac.class.default_options[:basic_auth][:username].must_equal username
    end

    it "auth[:password] should match the password provided" do
      uac.class.default_options[:basic_auth][:password].must_equal password
    end

    it "default_params[:format] should be set to json" do
      uac.class.default_params[:format].must_equal 'json'
    end

    it "should have a #username method" do
      uac.must_respond_to :username
    end
  end

  describe "querying Uptrends" do
    let(:uac) { Uptrends::Client.new(username: username, password: password) }

    describe "GET Probes" do
      before do
        VCR.insert_cassette('GET Probes', :record => :new_episodes, match_requests_on: [:method, :body, :headers, :query, :path])
        #Did you mean one of :method, :uri, :body, :headers, :host, :path, :query, :body_as_json?
      end

      after do
        VCR.eject_cassette
      end

      it "must has a #get_probes method" do
        uac.wont_respond_to :get_probes
      end

      it "must have a #probes method" do
        uac.must_respond_to :probes
      end

      it "should return an array of Uptrends::Probe objects" do
        probes = uac.probes
        probes.each do |probe|
          #puts probe.class
          probe.class.must_equal Uptrends::Probe
        end
      end
    end
  end
end