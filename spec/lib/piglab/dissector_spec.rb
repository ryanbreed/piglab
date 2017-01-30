require 'spec_helper'

describe Piglab::Dissector do
  context "default constructor" do
    let(:dissector) { Piglab::Dissector.new() }
    describe ".initialize" do
      it "sets the sample glob" do
        expect(dissector.sample_glob).to eq("extracts/text/*.txt")
      end
    end
  end
end
