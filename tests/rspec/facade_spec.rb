require 'rspec'
require_relative '../../src/app/facade'

Tagm8Db.open('tagm8-test')

describe Taxonomy do
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
  describe :delete_taxonomies do
    describe '1 of 1 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.delete_taxonomies('tax1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 1 taxonomies "tax1" found and deleted') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '2 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result = face.delete_taxonomies('tax1,tax2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('2 of 2 taxonomies "tax1,tax2" found and deleted') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '1 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result = face.delete_taxonomies('tax1,tax3')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 2 taxonomies "tax1,tax3" found and deleted') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '2 of 3 found and deleted with details' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      face.add_taxonomy('tax3')
      result = face.delete_taxonomies('tax1,tax2,tax4',true)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("taxonomy \"tax1\" deleted\ntaxonomy \"tax2\" deleted\n2 of 3 taxonomies \"tax1,tax2,tax4\" found and deleted") end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'no listed taxonomies found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result = face.delete_taxonomies('tax3,tax4')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_taxonomies "tax3,tax4" failed: no listed taxonomies found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy list missing - empty' do
      Tagm8Db.wipe
      face = Facade.instance
      result = face.delete_taxonomies('')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_taxonomies "" failed: taxonomy list missing') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy list missing - nil' do
      Tagm8Db.wipe
      face = Facade.instance
      result = face.delete_taxonomies(nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_taxonomies "nil:NilClass" failed: taxonomy list missing') end
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
    describe 'rename unchanged' do
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
end
describe Album do
  describe :add_album do
    describe 'name ok' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.add_album('tax1','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Album "alm1" added to taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      result = face.add_album('','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      result = face.add_album(nil,'alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      result = face.add_album('tax1','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "tax1" failed: taxonomy "tax1" not found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.add_album('tax1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "" to taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.add_album('tax1',nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "nil:NilClass" to taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'name taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_album('tax1','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "tax1" failed: album "alm1" taken by taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'name invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.add_album('tax1','alm%')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm%" to taxonomy "tax1" failed: album "alm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to be_nil end
    end
  end
  describe :delete_albums do
    describe '1 of 1 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.delete_albums('tax1','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 1 albums "alm1" found and deleted from taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '2 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result = face.delete_albums('tax1','alm1,alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('2 of 2 albums "alm1,alm2" found and deleted from taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '1 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result = face.delete_albums('tax1','alm1,alm3')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 2 albums "alm1,alm3" found and deleted from taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '2 of 3 found and deleted with details' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      face.add_album('tax1','alm3')
      result = face.delete_albums('tax1','alm1,alm2,alm4',true)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("album \"alm1\" deleted\nalbum \"alm2\" deleted\n2 of 3 albums \"alm1,alm2,alm4\" found and deleted from taxonomy \"tax1\"") end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'no listed albums found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result = face.delete_albums('tax1','alm3,alm4')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm3,alm4" from taxonomy "tax1" failed: no listed albums found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.delete_albums('','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.delete_albums(nil,'alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.delete_albums('tax2','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album list missing - empty' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.delete_albums('tax1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "" from taxonomy "tax1" failed: album list missing') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album list missing - nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result = face.delete_albums('tax1',nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "nil:NilClass" from taxonomy "tax1" failed: album list missing') end
      it "result data" do expect(result_data).to be_nil end
    end
  end
  describe :rename_album do
    describe 'rename valid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','alm1','alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Album renamed from "alm1" to "alm2" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('','alm1','alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album(nil,'alm1','alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax2','alm1','alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','','alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "" to "alm2" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1',nil,'alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "nil:NilClass" to "alm2" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','alm2','alm3')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm2" to "alm3" in taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','alm1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "" in taxonomy "tax1" failed: album rename unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','alm1',nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "nil:NilClass" in taxonomy "tax1" failed: album rename unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename unchanged' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','alm1','alm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm1" in taxonomy "tax1" failed: album rename unchanged') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result = face.rename_album('tax1','alm1','alm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "tax1" failed: album "alm2" taken by taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.rename_album('tax1','alm1','alm%')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm%" in taxonomy "tax1" failed: album "alm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to be_nil end
    end
  end
  describe :count_albums do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_taxonomy('tax3')
    describe 'taxonomy, album specified' do
      describe '1 found' do
        result_code,result_msg,*result_data = face.count_albums('tax1','alm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([1]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_albums('tax1','alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'taxonomy specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_albums('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_albums('tax3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'album specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_albums(nil,'alm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_albums(nil,'alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'nothing specified' do
      describe '3 found' do
        result_code,result_msg,*result_data = face.count_albums
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([3]) end
      end
    end
    describe 'taxonomy unspecified' do
      result_code,result_msg,*result_data = face.count_albums('','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_albums with name "alm1" in taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found, various error location msgs' do
      describe 'taxonomy, album specified' do
        result_code,result_msg,*result_data = face.count_albums('tax5','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_albums with name "alm1" in taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy specified' do
        result_code,result_msg,*result_data = face.count_albums('tax5')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_albums in taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'album unspecified' do
      result_code,result_msg,*result_data = face.count_albums('tax1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_albums with name "" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no taxonomies found, various locations for error msg' do
      Tagm8Db.wipe
      face = Facade.instance
      describe 'album specified' do
        result_code,result_msg,*result_data = face.count_albums(nil,'alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_albums with name "alm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'nothing specified' do
        result_code,result_msg,*result_data = face.count_albums
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_albums failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
end
describe Item do
  describe :add_item do
    describe 'name ok' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','alm1','itm1\n#tag1,tag2\ncontent line 1\ncontent line 2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      items = Item.list.sort
      alm1_items = Album.get_by_name('alm1').first.list_items.sort
      itm1 = Item.get_by_name('itm1').first
      itm1_name = itm1.name
      itm1_content = itm1.get_content
      tax1_tags = Taxonomy.get_by_name('tax1').list_tags.sort
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item "itm1" added to album "alm1" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
      it "items added OK" do expect(items).to eq(['itm1']) end
      it "alm1 items added OK" do expect(alm1_items).to eq(['itm1']) end
      it "itm1 name correct" do expect(itm1_name).to eq('itm1') end
      it "itm1 content correct" do expect(itm1_content).to eq("#tag1,tag2\ncontent line 1\ncontent line 2") end
      it "tax1 tags added OK" do expect(tax1_tags).to eq(['tag1','tag2']) end
    end
    describe 'name ok, stripping test' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','alm1','  itm1 \n#tag1,tag2 \n content line 1 \n content line 2 \n \n')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      items = Item.list.sort
      alm1_items = Album.get_by_name('alm1').first.list_items.sort
      itm1 = Item.get_by_name('itm1').first
      itm1_name = itm1.name
      itm1_content = itm1.get_content
      tax1_tags = Taxonomy.get_by_name('tax1').list_tags.sort
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item "itm1" added to album "alm1" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
      it "items added OK" do expect(items).to eq(['itm1']) end
      it "alm1 items added OK" do expect(alm1_items).to eq(['itm1']) end
      it "itm1 name correct" do expect(itm1_name).to eq('itm1') end
      it "itm1 content correct" do expect(itm1_content).to eq("#tag1,tag2 \n content line 1 \n content line 2") end
      it "tax1 tags added OK" do expect(tax1_tags).to eq(['tag1','tag2']) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('','alm1','itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item(nil,'alm1','itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax2','alm1','itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','','itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1',nil,'itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "nil:NilClass" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','alm2','itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm2" in taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','alm1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','alm1',nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'name taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.add_item('tax1','alm1','itm1\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item "itm1" taken by album "alm1" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'name invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result = face.add_item('tax1','alm1','itm%\ncontent1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item "itm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to be_nil end
    end
  end
  describe :delete_items do
    describe '1 of 1 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax1','alm1','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 1 items "itm1" found and deleted from album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '2 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result = face.delete_items('tax1','alm1','itm1,itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('2 of 2 items "itm1,itm2" found and deleted from album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '1 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result = face.delete_items('tax1','alm1','itm1,itm3')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 2 items "itm1,itm3" found and deleted from album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe '2 of 3 found and deleted with details' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      face.add_item('tax1','alm1','itm3\ncontent3')
      result = face.delete_items('tax1','alm1','itm1,itm2,itm4',true)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("item \"itm1\" deleted\nitem \"itm2\" deleted\n2 of 3 items \"itm1,itm2,itm4\" found and deleted from album \"alm1\" of taxonomy \"tax1\"") end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'associated tag deletion' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_tags('tax1','t1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\n#t1,t2,t3,t4\ncontent1')
      face.add_item('tax1','alm1','itm2\n#t3\ncontent2')
      face.add_tags('tax1','t2')
      result = face.delete_items('tax1','alm1','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      tax1 = Taxonomy.get_by_name('tax1')
      tax1_tags = tax1.list_tags.sort
      pre_independent_kept = tax1.has_tag?('t1')
      post_independent_kept = tax1.has_tag?('t2')
      dependent_with_item_kept = tax1.has_tag?('t3')
      dependent_without_item_deleted = !tax1.has_tag?('t4')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("1 of 1 items \"itm1\" found and deleted from album \"alm1\" of taxonomy \"tax1\"") end
      it "result data" do expect(result_data).to be_nil end
      it "correct tags remain" do expect(tax1_tags).to eq(['t1','t2','t3']) end
      it "independent tag added before items kept" do expect(pre_independent_kept).to be_truthy end
      it "independent tag added after items kept" do expect(post_independent_kept).to be_truthy end
      it "dependent tag with items kept" do expect(dependent_with_item_kept).to be_truthy end
      it "dependent tag without items deleted" do expect(dependent_without_item_deleted).to be_truthy end
    end
    describe 'no listed items found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result = face.delete_items('tax1','alm1','itm3,itm4')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm3,itm4" from album "alm1" of taxonomy "tax1" failed: no listed items found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('','alm1','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items(nil,'alm1','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax2','alm1','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax1','','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax1',nil,'itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "nil:NilClass" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax1','alm2','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm2" of taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item list missing - empty' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax1','alm1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "" from album "alm1" of taxonomy "tax1" failed: item list missing') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item list missing - nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.delete_items('tax1','alm1',nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "nil:NilClass" from album "alm1" of taxonomy "tax1" failed: item list missing') end
      it "result data" do expect(result_data).to be_nil end
    end
  end
  describe :rename_item do
    describe 'rename valid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item renamed from "itm1" to "itm2" in album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('','alm1','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item(nil,'alm1','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax2','alm1','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1',nil,'itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "nil:NilClass" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm2','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm2" of taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "" to "itm2" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1',nil,'itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "nil:NilClass" to "itm2" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'item not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','itm','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm" to "itm2" in album "alm1" of taxonomy "tax1" failed: item "itm" not found in album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','itm1','')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "" in album "alm1" of taxonomy "tax1" failed: item rename unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','itm1',nil)
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "nil:NilClass" in album "alm1" of taxonomy "tax1" failed: item rename unspecified') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename unchanged' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','itm1','itm1')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm1" in album "alm1" of taxonomy "tax1" failed: item rename unchanged') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result = face.rename_item('tax1','alm1','itm1','itm2')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "tax1" failed: item "itm2" name taken by album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to be_nil end
    end
    describe 'rename invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result = face.rename_item('tax1','alm1','itm1','itm%')
      result_code = result[0]
      result_msg  = result[1]
      result_data = result[2]
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm%" in album "alm1" of taxonomy "tax1" failed: item "itm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to be_nil end
    end
  end
  describe :count_items do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1')
    face.add_item('tax1','alm1','itm2\ncontent2')
    face.add_album('tax1','alm2')
    face.add_item('tax1','alm2','itm2\ncontent2')
    face.add_album('tax1','alm3')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_item('tax2','alm1','itm1\ncontent1')
    face.add_album('tax2','alm2')
    face.add_item('tax2','alm2','itm2\ncontent2')
    face.add_album('tax2','alm3')
    face.add_taxonomy('tax3')
    face.add_album('tax3','alm1')
    face.add_taxonomy('tax4')
    describe 'taxonomy, album, name specified' do
      describe '1 found' do
        result_code,result_msg,*result_data = face.count_items('tax1','alm1','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([1]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items('tax1','alm2','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'taxonomy, album specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_items('tax1','alm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items('tax1','alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'taxonomy, name specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_items('tax1',nil,'itm2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items('tax1',nil,'itm4')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'album, name specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm1','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm2','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'taxonomy specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_items('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items('tax3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'album specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'name specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_items(nil,nil,'itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_items(nil,nil,'itm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'nothing specified' do
      result_code,result_msg,*result_data = face.count_items
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('') end
      it "result data" do expect(result_data).to eq([5]) end
    end
    describe 'taxonomy unspecified' do
      result_code,result_msg,*result_data = face.count_items('','alm1','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found, various error location msgs' do
      describe 'taxonomy, album, item specified' do
        result_code,result_msg,*result_data = face.count_items('tax5','alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy, album specified' do
        result_code,result_msg,*result_data = face.count_items('tax5','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy, name specified' do
        result_code,result_msg,*result_data = face.count_items('tax5',nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy specified' do
        result_code,result_msg,*result_data = face.count_items('tax5')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'album unspecified' do
      result_code,result_msg,*result_data = face.count_items('tax1','','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found in taxonomy' do
      result_code,result_msg,*result_data = face.count_items('tax3','alm2','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm2" of taxonomy "tax3" failed: album "alm2" not found in taxonomy "tax3"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found' do
      result_code,result_msg,*result_data = face.count_items(nil,'alm4','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm4" failed: album "alm4" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no albums found in taxonomy' do
      result_code,result_msg,*result_data = face.count_items('tax4')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items of taxonomy "tax4" failed: no albums found in taxonomy "tax4"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name unspecified' do
      result_code,result_msg,*result_data = face.count_items('tax1','alm1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items with name "" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no taxonomies found, various locations for error msg' do
      Tagm8Db.wipe
      face = Facade.instance
      describe 'album, name specified' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" in album "alm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album specified' do
        result_code,result_msg,*result_data = face.count_items(nil,'alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items in album "alm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item specified' do
        result_code,result_msg,*result_data = face.count_items(nil,nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items with name "itm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'nothing specified' do
        result_code,result_msg,*result_data = face.count_items(nil,nil,nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('count_items failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'no albums found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.count_items(nil,nil,'itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_items with name "itm1" failed: no albums found') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :list_items do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1')
    face.add_item('tax1','alm1','itm2\ncontent2.1 \n content 2.2#t1,t2 \n content2.3 \n \n')
    face.add_album('tax1','alm2')
    face.add_item('tax1','alm2','itm2\ncontent2')
    face.add_album('tax1','alm3')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_item('tax2','alm1','itm1\ncontent1')
    face.add_album('tax2','alm2')
    face.add_item('tax2','alm2','itm2\ncontent2')
    face.add_album('tax2','alm3')
    face.add_taxonomy('tax3')
    face.add_album('tax3','alm1')
    face.add_taxonomy('tax4')
    describe 'taxonomy, album, name specified' do
      describe '1 found' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 item found with name "itm1" in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['itm1']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm2','itm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found with name "itm1" in album "alm2" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'taxonomy, album specified, with[out] reverse|details|content' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['itm1','itm2']) end
      end
      describe '2 found reversed' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['itm2','itm1']) end
      end
      describe '2 found with details' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm2            alm1               tax1      2     ']) end
      end
      describe '2 found with content' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,false,false,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(["item \"itm1\" in album \"alm1\" of taxonomy \"tax1\" has 0 tags:\n\ncontent1\n\n","item \"itm2\" in album \"alm1\" of taxonomy \"tax1\" has 2 tags:\n\ncontent2.1 \n content 2.2#t1,t2 \n content2.3\n\n"]) end
      end
      describe '2 found reversed with details' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm1',nil,true,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found in album "alm1" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['item "itm2" in album "alm1" of taxonomy "tax1" has 2 tags','      itm1            alm1               tax1      0     ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items('tax1','alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found in album "alm3" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'taxonomy, name specified, details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_items('tax1',nil,'itm2',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found with name "itm2" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['item "itm2" in album "alm1" of taxonomy "tax1" has 2 tags','      itm2            alm2               tax1      0     ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items('tax1',nil,'itm4',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found with name "itm4" of taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'album, name specified, details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm1','itm1',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found with name "itm1" in album "alm1"') end
        it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm2','itm1',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found with name "itm1" in album "alm2"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'taxonomy specified, details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_items('tax2',nil,nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found of taxonomy "tax2"') end
        it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax2" has 0 tags','      itm2            alm2               tax2      0     ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items('tax3',nil,nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found of taxonomy "tax3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'album specified, details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm2',nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found in album "alm2"') end
        it "result data" do expect(result_data).to eq(['item "itm2" in album "alm2" of taxonomy "tax1" has 0 tags','      itm2            alm2               tax2      0     ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm3',nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found in album "alm3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'name specified, details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_items(nil,nil,'itm1',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 items found with name "itm1"') end
        it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_items(nil,nil,'itm3',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no items found with name "itm3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'nothing specified, details' do
      result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('5 items found') end
      it "result data" do expect(result_data).to eq(['item "itm1" in album "alm1" of taxonomy "tax1" has 0 tags','      itm1            alm1               tax2      0     ','      itm2            alm1               tax1      2     ','      itm2            alm2               tax1      0     ','      itm2            alm2               tax2      0     ']) end
    end
    describe 'taxonomy unspecified' do
      result_code,result_msg,*result_data = face.list_items('','alm1','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found, various error location msgs' do
      describe 'taxonomy, album, item specified' do
        result_code,result_msg,*result_data = face.list_items('tax5','alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy, album specified' do
        result_code,result_msg,*result_data = face.list_items('tax5','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items in album "alm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy, name specified' do
        result_code,result_msg,*result_data = face.list_items('tax5',nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy specified' do
        result_code,result_msg,*result_data = face.list_items('tax5')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items of taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'album unspecified' do
      result_code,result_msg,*result_data = face.list_items('tax1','','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found in taxonomy' do
      result_code,result_msg,*result_data = face.list_items('tax3','alm2','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm2" of taxonomy "tax3" failed: album "alm2" not found in taxonomy "tax3"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found' do
      result_code,result_msg,*result_data = face.list_items(nil,'alm4','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm4" failed: album "alm4" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no albums found in taxonomy' do
      result_code,result_msg,*result_data = face.list_items('tax4')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items of taxonomy "tax4" failed: no albums found in taxonomy "tax4"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name unspecified' do
      result_code,result_msg,*result_data = face.list_items('tax1','alm1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items with name "" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no taxonomies found, various locations for error msg' do
      Tagm8Db.wipe
      face = Facade.instance
      describe 'album, name specified' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm1','itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" in album "alm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'album specified' do
        result_code,result_msg,*result_data = face.list_items(nil,'alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items in album "alm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'item specified' do
        result_code,result_msg,*result_data = face.list_items(nil,nil,'itm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items with name "itm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'nothing specified' do
        result_code,result_msg,*result_data = face.list_items(nil,nil,nil)
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_items failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'no albums found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.list_items(nil,nil,'itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_items with name "itm1" failed: no albums found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'details 11 results' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm01\ncontent1')
      face.add_item('tax1','alm1','itm02\ncontent2')
      face.add_item('tax1','alm1','itm03\ncontent1')
      face.add_item('tax1','alm1','itm04\ncontent2')
      face.add_item('tax1','alm1','itm05\ncontent1')
      face.add_item('tax1','alm1','itm06\ncontent2')
      face.add_item('tax1','alm1','itm07\ncontent1')
      face.add_item('tax1','alm1','itm08\ncontent2')
      face.add_item('tax1','alm1','itm09\ncontent1')
      face.add_item('tax1','alm1','itm10\ncontent2')
      face.add_item('tax1','alm1','itm11\ncontent1')
      result_code,result_msg,*result_data = face.list_items(nil,nil,nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 items found') end
      it "result data" do expect(result_data).to eq(['item "itm01" in album "alm1" of taxonomy "tax1" has 0 tags','      itm02            alm1               tax1      0     ','      itm03            alm1               tax1      0     ','      itm04            alm1               tax1      0     ','      itm05            alm1               tax1      0     ','      itm06            alm1               tax1      0     ','      itm07            alm1               tax1      0     ','      itm08            alm1               tax1      0     ','      itm09            alm1               tax1      0     ','      itm10            alm1               tax1      0     ','item "itm11" in album "alm1" of taxonomy "tax1" has 0 tags']) end
    end
  end
end




