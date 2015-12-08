require 'spec_helper'

describe 'daemon' do

  describe service('my-program') do
    it { should be_enabled }
    it { should_not be_running }
  end

  describe process('my-program') do
    it { should_not be_running }
  end

end
