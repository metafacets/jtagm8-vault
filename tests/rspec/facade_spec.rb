require 'rspec'
require_relative '../../src/app/facade'

Tagm8Db.open('tagm8-test')

describe :add_taxonomy do
  describe 'name ok, dag default' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax1')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(0) end
    it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'name ok, dag prevent' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax1','prevent')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(0) end
    it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'name ok, dag fix' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax1','fix')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(0) end
    it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'name ok, dag invalid' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax1','invalid')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: dag "invalid" invalid - use prevent, fix or free') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'taxonomy unspecified' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "" failed: taxonomy unspecified') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'taxonomy nil' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy(nil)
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "nil:NilClass" failed: taxonomy unspecified') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'name taken' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.add_taxonomy('tax1')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: "tax1" taken') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'name invalid' do
    Tagm8Db.wipe
    face = Facade.instance
    result = face.add_taxonomy('tax%')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('add_taxonomy "tax%" failed: "tax%" invalid - use alphanumeric and _ characters only') end
    it "result data" do expect(result_data).to be_nil end
  end
end
describe :rename_taxonomy do
  describe 'rename valid' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.rename_taxonomy('tax1','tax2')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(0) end
    it "result message" do expect(result_msg).to eq('Taxonomy "tax1" renamed to "tax2"') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'taxonomy unspecified' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.rename_taxonomy('','tax2')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "" to "tax2" failed: taxonomy unspecified') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'taxonomy nil' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.rename_taxonomy(nil,'tax2')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "nil:NilClass" to "tax2" failed: taxonomy unspecified') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'rename unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.rename_taxonomy('tax1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "" failed: taxonomy rename unspecified') end
      it "result data" do expect(result_data).to be_nil end
  end
  describe 'rename nil' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.rename_taxonomy('tax1',nil)
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "nil:NilClass" failed: taxonomy rename unspecified') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'name unchanged' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.rename_taxonomy('tax1','tax1')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax1" failed: rename unchanged') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'taxonomy not found' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax')
    result = face.rename_taxonomy('tax1','tax2')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax2" failed: "tax1" not found') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'rename taken' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_taxonomy('tax2')
    result = face.rename_taxonomy('tax1','tax2')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax2" failed: "tax2" taken') end
    it "result data" do expect(result_data).to be_nil end
  end
  describe 'rename invalid' do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    result = face.rename_taxonomy('tax1','tax%')
    result_code = result[0]
    result_msg  = result[1]
    result_data = result[2]
    it "result_code" do expect(result_code).to eq(1) end
    it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax%" failed: "tax%" invalid - use alphanumeric and _ characters only') end
    it "result data" do expect(result_data).to be_nil end
  end
end



