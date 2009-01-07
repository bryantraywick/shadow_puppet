require File.dirname(__FILE__) + '/spec_helper.rb'

describe "A manifest" do

  before(:each) do
    @manifest = BlankManifest.new
  end

  describe "when blank" do

    it "should have no instance level roles defined" do
      @manifest.instance_roles.should have(0).items
    end

    it "should have no class level roles defined" do
      BlankManifest.class_roles.should have(0).items
    end

  end

  describe "with class level roles" do

    before(:each) do
      @manifest = ClassLevelRole.new
    end

    it "should have no instance level roles defined" do
      @manifest.instance_roles.should have(0).items
    end

    it "should have appropriate class level roles defined" do
      ClassLevelRole.class_roles.should have(1).items
    end

    it "should create puppet aspects from the class roles" do
      lambda { Puppet::DSL::Aspect[:debug] }.should_not raise_error
    end

  end

  describe "with instance level roles" do

    before(:each) do
      @manifest = BlankManifest.new
      @manifest.role :debug do
        exec "whoami", :command => "/usr/bin/whoami > /tmp/whoami.txt"
      end
    end

    it "should have no class level roles defined" do
      BlankManifest.class_roles.should have(0).items
    end

    it "should have appropriate instance level roles defined" do
      @manifest.instance_roles.should have(1).items
    end

    it "should create puppet aspects from the instance roles" do
      lambda { Puppet::DSL::Aspect[:debug] }.should_not raise_error
    end

  end

  describe "dependencies" do
    before(:each) do
      @manifest = BlankManifest.new
      @aspect = @manifest.role :debug do
        exec "whoami", :command => "/usr/bin/whoami > /tmp/whoami.txt"
      end
    end

    it "should be able to be created using the 'reference' method" do
      @aspect.reference(:exec, "whoami").to_ref.should == ['exec', 'whoami']
    end

    it "should be able to be created using a call to the named method with only one arg" do
      @aspect.exec("whoami").to_ref.should == ['exec', 'whoami']
    end

  end

end

describe "Executing a manifest" do
  before(:each) do
    @manifest = ClassLevelRole.new
    @aspect = @manifest.role "uname" do
      exec "uname", :command => "/usr/bin/uname > /tmp/uname.txt"
    end
  end

  it "should acquire all defined roles" do
    @manifest.should_receive(:apply_roles).with(:debug,:uname)
    @manifest.run
  end

  it "should perform all tasks" do
    @manifest.run
    File.read("/tmp/uname.txt").should == `uname`
    File.read("/tmp/whoami.txt").should == `whoami`
  end

  after(:each) do
    begin
      File.delete("/tmp/uname.txt")
      File.delete("/tmp/whoami.txt")
    rescue
    end
  end
end