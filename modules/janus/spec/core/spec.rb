require 'spec_helper'

describe 'janus' do

  describe user('janus') do
    it { should exist }
  end

  describe service('janus_edge1') do
    it { should be_enabled }
    it { should be_running }
  end
end
