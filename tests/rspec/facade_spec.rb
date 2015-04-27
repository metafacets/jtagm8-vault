require 'rspec'
require_relative '../../src/app/facade'

Tagm8Db.open('tagm8-test')

describe :add_taxonomy do
  describe 'add valid' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax1')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(0) end
    it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
    it "result data" do expect(result_data).to eq('') end
  end
  describe 'add existing' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.add_taxonomy('tax1')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: name taken') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'add invalid' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax%')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "tax%" failed: name invalid - use alphanumeric and _ characters only') end
    it "result data" do expect(result_data).to be_nil end
  end

end



