require "./spec_helper"

describe "PDF Document State" do
  _state = PDF::Core::DocumentState.new({"test" => "d"})

  describe "initialization" do
    it "compress should be false" { expect(_state.compress).to eq(false) }
    it "encrypt should be false" { expect(_state.encrypt).to eq(false) }
    it "skip_encoding should be false" { expect(_state.skip_encoding).to eq(false) }
    # it { expect(@state.trailer).to eq({}) }
  end

  describe "normalize_metadata" do
    it "normalizes the Creator" { expect(_state.store.info.data[:Creator]).to eq("Prawn") }
    it "normalizes the Producer" { expect(_state.store.info.data[:Producer]).to eq("Prawn") }
  end

  describe "given a trailer ID with two values" do
      _state = PDF::Core::DocumentState.new({
        trailer: { :ID => ["myDoc","versionA"] }
      })

    it "should contain the ID entry with two values in trailer" do
      expect(_state.trailer[:ID].count).to eq(2)
    end
  end

end
