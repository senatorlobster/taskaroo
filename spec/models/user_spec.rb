require 'spec_helper'
require 'ostruct'

describe User do

  describe "validation tests" do

    before(:each) do
      @new_user = User.new(uid: '12345', provider: 'twitter', nickname: 'eshizzle')
    end

    it "is invalid if it doesn't have a uid" do

      @new_user.uid = nil
      @new_user.should_not be_valid
    end

    it "is invalid if it doesn't have a provider" do

      @new_user.provider = nil
      @new_user.should_not be_valid
    end

    it "is invalid if it doesn't have a nickname" do

      @new_user.nickname = nil
      @new_user.should_not be_valid
    end
  end

  describe "#retrieve_or_create" do

    before(:each) do
      # @auth_hash = {uid: '12345', provider: 'twitter', nickname: 'eshizzle'}
      @auth_hash = OpenStruct.new(uid: '12345', provider: 'twitter', info: OpenStruct.new(nickname: 'eshizzle') )
    end

    it "returns user corresponding to auth_hash if user doesn't exist" do

      user = User.retrieve_or_create(@auth_hash)
      user.should be_valid
      user.nickname.should eql @auth_hash[:info][:nickname]
      user.uid.should eql @auth_hash[:uid]
      user.provider.should eql @auth_hash[:provider]
    end

    it "returns user corresponding to auth_hash if user *does* exist" do

      new_user = User.create(uid: '12345', provider: 'twitter', nickname: 'eshizzle')

      existing_user = User.retrieve_or_create(@auth_hash)
      existing_user.should be_valid
      existing_user.should eql new_user
    end
  end
end
