require "spec_helper"

RSpec.describe Piglab do
  it "has a version number" do
    expect(Piglab::VERSION).not_to be nil
  end

  describe "Piglab.project" do
    it "configures a project instance" do
      expect(Piglab.project).to be_a(Piglab::Project)
    end
    it "passes configuration into the class constructor" do
      project=Piglab.project(root: "tmp")
      expect(project.root).to eq("tmp")
    end
  end
end
