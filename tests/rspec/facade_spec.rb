require 'rspec'
require_relative '../../src/app/facade'

Tagm8Db.open('tagm8-test')

describe Taxonomy do
  describe :add_taxonomy do
    describe 'name ok, dag default' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy('tax1')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name ok, dag prevent' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy('tax1','prevent')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name ok, dag fix' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy('tax1','fix')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Taxonomy "tax1" added') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name ok, dag invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy('tax1','invalid')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: dag "invalid" invalid - use prevent, fix or free') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy('')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy(nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_taxonomy('tax1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_taxonomy "tax1" failed: "tax1" taken') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_taxonomy('tax%')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_taxonomy "tax%" failed: "tax%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :delete_taxonomies do
    describe '1 of 1 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.delete_taxonomies('tax1')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 1 taxonomies "tax1" found and deleted') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '2 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result_code,result_msg,*result_data = face.delete_taxonomies('tax1,tax2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('2 of 2 taxonomies "tax1,tax2" found and deleted') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '1 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result_code,result_msg,*result_data = face.delete_taxonomies('tax1,tax3')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 2 taxonomies "tax1,tax3" found and deleted') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '2 of 3 found and deleted with details' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      face.add_taxonomy('tax3')
      result_code,result_msg,*result_data = face.delete_taxonomies('tax1,tax2,tax4',true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("taxonomy \"tax1\" deleted\ntaxonomy \"tax2\" deleted\n2 of 3 taxonomies \"tax1,tax2,tax4\" found and deleted") end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no listed taxonomies found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result_code,result_msg,*result_data = face.delete_taxonomies('tax3,tax4')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_taxonomies "tax3,tax4" failed: no listed taxonomies found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy list missing - empty' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.delete_taxonomies('')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_taxonomies "" failed: taxonomy list missing') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy list missing - nil' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.delete_taxonomies(nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_taxonomies "nil:NilClass" failed: taxonomy list missing') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :rename_taxonomy do
    describe 'rename valid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Taxonomy "tax1" renamed to "tax2"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy('','tax2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "" to "tax2" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy(nil,'tax2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "nil:NilClass" to "tax2" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax2" failed: "tax1" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename unspecified' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.rename_taxonomy('tax1','')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "" failed: taxonomy rename unspecified') end
        it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "nil:NilClass" failed: taxonomy rename unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename unchanged' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax1" failed: rename unchanged') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_taxonomy('tax2')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax2" failed: "tax2" taken') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.rename_taxonomy('tax1','tax%')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_taxonomy "tax1" to "tax%" failed: "tax%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :count_taxonomies do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_taxonomy('tax2')
    describe 'taxonomy specified' do
      describe '1 found' do
        result_code,result_msg,*result_data = face.count_taxonomies('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([1]) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.count_taxonomies('tax3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([0]) end
      end
    end
    describe 'nothing specified' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.count_taxonomies
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('') end
        it "result data" do expect(result_data).to eq([2]) end
      end
    end
    describe 'taxonomy unspecified' do
      result_code,result_msg,*result_data = face.count_taxonomies('')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('count_taxonomies with name "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :list_taxonomies do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1 #t1>t2 #f1')
    face.add_item('tax1','alm1','itm2\ncontent2')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_taxonomy('tax3')
    describe 'taxonomy specified' do
      describe '1 found' do
        result_code,result_msg,*result_data = face.list_taxonomies('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 taxonomy found with name "tax1"') end
        it "result data" do expect(result_data).to eq(['tax1']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_taxonomies('tax')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no taxonomies found with name "tax"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'nothing specified with[out] reverse|details' do
      describe '3 found' do
        result_code,result_msg,*result_data = face.list_taxonomies
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 taxonomies found') end
        it "result data" do expect(result_data).to eq(['tax1','tax2','tax3']) end
      end
      describe '3 found reversed' do
        result_code,result_msg,*result_data = face.list_taxonomies(nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 taxonomies found') end
        it "result data" do expect(result_data).to eq(['tax3','tax2','tax1']) end
      end
      describe '3 found with details' do
        result_code,result_msg,*result_data = face.list_taxonomies(nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 taxonomies found') end
        it "result data" do expect(result_data).to eq(['taxonomy "tax1" DAG: prevent has 3 tags, 1 roots, 1 folks, 1 links and 2 albums','          tax2       prevent     0       0        0        0           1        ','          tax3       prevent     0       0        0        0           0        ']) end
      end
      describe '3 found reversed with details' do
        result_code,result_msg,*result_data = face.list_taxonomies(nil,true,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 taxonomies found') end
        it "result data" do expect(result_data).to eq(['taxonomy "tax3" DAG: prevent has 0 tags, 0 roots, 0 folks, 0 links and 0 albums','          tax2       prevent     0       0        0        0           1        ','          tax1       prevent     3       1        1        1           2        ']) end
      end
    end
    describe 'taxonomy unspecified' do
      result_code,result_msg,*result_data = face.list_taxonomies('')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_taxonomies with name "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'details 11 results, with various albums, items and tags added' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax01')
      face.add_album('tax01','alm1')
      face.add_item('tax01','alm1','itm1\ncontent1 #f1,t1>t2')
      face.add_item('tax01','alm1','itm2\ncontent2')
      face.add_album('tax01','alm2')
      face.add_taxonomy('tax02')
      face.add_album('tax02','alm1')
      face.add_taxonomy('tax03')
      face.add_taxonomy('tax04')
      face.add_taxonomy('tax05')
      face.add_taxonomy('tax06')
      face.add_taxonomy('tax07')
      face.add_taxonomy('tax08')
      face.add_taxonomy('tax09')
      face.add_taxonomy('tax10')
      face.add_taxonomy('tax11')
      result_code,result_msg,*result_data = face.list_taxonomies(nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 taxonomies found') end
      it "result data" do expect(result_data).to eq(['taxonomy "tax01" DAG: prevent has 3 tags, 1 roots, 1 folks, 1 links and 2 albums','          tax02       prevent     0       0        0        0           1        ','          tax03       prevent     0       0        0        0           0        ','          tax04       prevent     0       0        0        0           0        ','          tax05       prevent     0       0        0        0           0        ','          tax06       prevent     0       0        0        0           0        ','          tax07       prevent     0       0        0        0           0        ','          tax08       prevent     0       0        0        0           0        ','          tax09       prevent     0       0        0        0           0        ','          tax10       prevent     0       0        0        0           0        ','taxonomy "tax11" DAG: prevent has 0 tags, 0 roots, 0 folks, 0 links and 0 albums']) end
    end
  end
end
describe Album do
  describe :add_album do
    describe 'name ok' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_album('tax1','alm1')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Album "alm1" added to taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_album('','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_album(nil,'alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_album('tax1','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "tax1" failed: taxonomy "tax1" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_album('tax1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "" to taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_album('tax1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "nil:NilClass" to taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_album('tax1','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm1" to taxonomy "tax1" failed: album "alm1" taken by taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_album('tax1','alm%')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_album "alm%" to taxonomy "tax1" failed: album "alm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :delete_albums do
    describe '1 of 1 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.delete_albums('tax1','alm1')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 1 albums "alm1" found and deleted from taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '2 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result_code,result_msg,*result_data = face.delete_albums('tax1','alm1,alm2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('2 of 2 albums "alm1,alm2" found and deleted from taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '1 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result_code,result_msg,*result_data = face.delete_albums('tax1','alm1,alm3')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 2 albums "alm1,alm3" found and deleted from taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '2 of 3 found and deleted with details' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      face.add_album('tax1','alm3')
      result_code,result_msg,*result_data = face.delete_albums('tax1','alm1,alm2,alm4',true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("album \"alm1\" deleted\nalbum \"alm2\" deleted\n2 of 3 albums \"alm1,alm2,alm4\" found and deleted from taxonomy \"tax1\"") end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.delete_albums('','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.delete_albums(nil,'alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.delete_albums('tax2','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm1" from taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album list missing - empty' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.delete_albums('tax1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "" from taxonomy "tax1" failed: album list missing') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album list missing - nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.delete_albums('tax1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "nil:NilClass" from taxonomy "tax1" failed: album list missing') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no listed albums found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result_code,result_msg,*result_data = face.delete_albums('tax1','alm3,alm4')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_albums "alm3,alm4" from taxonomy "tax1" failed: no listed albums found') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :rename_album do
    describe 'rename valid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Album renamed from "alm1" to "alm2" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('','alm1','alm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album(nil,'alm1','alm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax2','alm1','alm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','','alm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "" to "alm2" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1',nil,'alm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "nil:NilClass" to "alm2" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm2','alm3')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm2" to "alm3" in taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "" in taxonomy "tax1" failed: album rename unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "nil:NilClass" in taxonomy "tax1" failed: album rename unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename unchanged' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm1" in taxonomy "tax1" failed: album rename unchanged') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_album('tax1','alm2')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm2" in taxonomy "tax1" failed: album "alm2" taken by taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.rename_album('tax1','alm1','alm%')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_album "alm1" to "alm%" in taxonomy "tax1" failed: album "alm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to eq([]) end
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
  describe :list_albums do
    Tagm8Db.wipe
    face = Facade.instance
    face.add_taxonomy('tax1')
    face.add_album('tax1','alm1')
    face.add_item('tax1','alm1','itm1\ncontent1')
    face.add_item('tax1','alm1','itm2\ncontent2')
    face.add_album('tax1','alm2')
    face.add_taxonomy('tax2')
    face.add_album('tax2','alm1')
    face.add_taxonomy('tax3')
    describe 'taxonomy, album specified' do
      describe '1 found' do
        result_code,result_msg,*result_data = face.list_albums('tax1','alm1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 album found with name "alm1" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['alm1']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_albums('tax1','alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no albums found with name "alm3" in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'taxonomy specified with[out] reverse|details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_albums('tax1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['alm1','alm2']) end
      end
      describe '2 found reversed' do
        result_code,result_msg,*result_data = face.list_albums('tax1',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['alm2','alm1']) end
      end
      describe '2 found with details' do
        result_code,result_msg,*result_data = face.list_albums('tax1',nil,false,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm2               tax1      0      ']) end
      end
      describe '2 found reversed with details' do
        result_code,result_msg,*result_data = face.list_albums('tax1',nil,true,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 albums found in taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq(['album "alm2" in taxonomy "tax1" has 0 items','       alm1               tax1      2      ']) end
      end
    end
    describe 'album specified, details' do
      describe '2 found' do
        result_code,result_msg,*result_data = face.list_albums(nil,'alm1',nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 albums found with name "alm1"') end
        it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm1               tax2      0      ']) end
      end
      describe 'none found' do
        result_code,result_msg,*result_data = face.list_albums(nil,'alm3')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('no albums found with name "alm3"') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'nothing specified' do
      describe '3 found' do
        result_code,result_msg,*result_data = face.list_albums
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 albums found') end
        it "result data" do expect(result_data).to eq(['alm1','alm1','alm2']) end
      end
      describe '3 found with details' do
        result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 albums found') end
        it "result data" do expect(result_data).to eq(['album "alm1" in taxonomy "tax1" has 2 items','       alm1               tax2      0      ','       alm2               tax1      0      ']) end
      end
      describe '3 found reversed with details' do
        result_code,result_msg,*result_data = face.list_albums(nil,nil,true,true)
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 albums found') end
        it "result data" do expect(result_data).to eq(['album "alm2" in taxonomy "tax1" has 0 items','       alm1               tax2      0      ','       alm1               tax1      2      ']) end
      end
    end
    describe 'taxonomy unspecified' do
      result_code,result_msg,*result_data = face.list_albums('','alm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_albums with name "alm1" in taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found, various error location msgs' do
      describe 'taxonomy, album specified' do
        result_code,result_msg,*result_data = face.list_albums('tax5','alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_albums with name "alm1" in taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'taxonomy specified' do
        result_code,result_msg,*result_data = face.list_albums('tax5')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_albums in taxonomy "tax5" failed: taxonomy "tax5" not found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'album unspecified' do
      result_code,result_msg,*result_data = face.list_albums('tax1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('list_albums with name "" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no taxonomies found, various locations for error msg' do
      Tagm8Db.wipe
      face = Facade.instance
      describe 'album specified' do
        result_code,result_msg,*result_data = face.list_albums(nil,'alm1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_albums with name "alm1" failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe 'nothing specified' do
        result_code,result_msg,*result_data = face.list_albums
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('list_albums failed: no taxonomies found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
    describe 'details 11 results' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm01')
      face.add_item('tax1','alm01','itm1\ncontent1')
      face.add_item('tax1','alm01','itm2\ncontent2')
      face.add_item('tax1','alm01','itm3\ncontent1')
      face.add_album('tax1','alm02')
      face.add_album('tax1','alm03')
      face.add_item('tax1','alm03','itm4\ncontent2')
      face.add_item('tax1','alm03','itm5\ncontent1')
      face.add_album('tax1','alm04')
      face.add_album('tax1','alm05')
      face.add_album('tax1','alm06')
      face.add_album('tax1','alm07')
      face.add_album('tax1','alm08')
      face.add_album('tax1','alm09')
      face.add_album('tax1','alm10')
      face.add_album('tax1','alm11')
      result_code,result_msg,*result_data = face.list_albums(nil,nil,nil,true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('11 albums found') end
      it "result data" do expect(result_data).to eq(['album "alm01" in taxonomy "tax1" has 3 items','       alm02               tax1      0      ','       alm03               tax1      2      ','       alm04               tax1      0      ','       alm05               tax1      0      ','       alm06               tax1      0      ','       alm07               tax1      0      ','       alm08               tax1      0      ','       alm09               tax1      0      ','       alm10               tax1      0      ','album "alm11" in taxonomy "tax1" has 0 items']) end
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
      result_code,result_msg,*result_data = face.add_item('tax1','alm1','itm1\n#tag1,tag2\ncontent line 1\ncontent line 2')
      items = Item.list.sort
      alm1_items = Album.get_by_name('alm1').first.list_items.sort
      itm1 = Item.get_by_name('itm1').first
      itm1_name = itm1.name
      itm1_content = itm1.get_content
      tax1_tags = Taxonomy.get_by_name('tax1').list_tags.sort
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item "itm1" added to album "alm1" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
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
      result_code,result_msg,*result_data = face.add_item('tax1','alm1','  itm1 \n#tag1>tag2,tag3 \n content line 1 \n content line 2 \n \n')
      items = Item.list.sort
      alm1_items = Album.get_by_name('alm1').first.list_items.sort
      itm1 = Item.get_by_name('itm1').first
      itm1_name = itm1.name
      itm1_content = itm1.get_content
      tax1 = Taxonomy.get_by_name('tax1')
      tax1_tag_count = tax1.count_tags
      tax1_tags = tax1.list_tags.sort
      tax1_root_count = tax1.count_roots
      tax1_roots = tax1.list_roots.sort
      tax1_folk_count = tax1.count_folksonomies
      tax1_folks = tax1.list_folksonomies.sort
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item "itm1" added to album "alm1" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
      it "items added OK" do expect(items).to eq(['itm1']) end
      it "alm1 items added OK" do expect(alm1_items).to eq(['itm1']) end
      it "itm1 name correct" do expect(itm1_name).to eq('itm1') end
      it "itm1 content correct" do expect(itm1_content).to eq("#tag1>tag2,tag3 \n content line 1 \n content line 2") end
      it "tax1 tag count OK" do expect(tax1_tag_count).to eq(3) end
      it "tax1 root count OK" do expect(tax1_root_count).to eq(1) end
      it "tax1 folk count OK" do expect(tax1_folk_count).to eq(1) end
      it "tax1 coorect tags added" do expect(tax1_tags).to eq(['tag1','tag2','tag3']) end
      it "tax1 correct roots added" do expect(tax1_roots).to eq(['tag1']) end
      it "tax1 correct folks added" do expect(tax1_folks).to eq(['tag3']) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('','alm1','itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item(nil,'alm1','itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax2','alm1','itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax1','','itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax1',nil,'itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "nil:NilClass" in taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax1','alm2','itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm2" in taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax1','alm1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax1','alm1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.add_item('tax1','alm1','itm1\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item "itm1" taken by album "alm1" in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'name invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      result_code,result_msg,*result_data = face.add_item('tax1','alm1','itm%\ncontent1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_item to album "alm1" in taxonomy "tax1" failed: item "itm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :delete_items do
    describe '1 of 1 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 1 items "itm1" found and deleted from album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '2 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1,itm2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('2 of 2 items "itm1,itm2" found and deleted from album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '1 of 2 found and deleted' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1,itm3')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('1 of 2 items "itm1,itm3" found and deleted from album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe '2 of 3 found and deleted with details' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      face.add_item('tax1','alm1','itm3\ncontent3')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1,itm2,itm4',true)
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("item \"itm1\" deleted\nitem \"itm2\" deleted\n2 of 3 items \"itm1,itm2,itm4\" found and deleted from album \"alm1\" of taxonomy \"tax1\"") end
      it "result data" do expect(result_data).to eq([]) end
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
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm1')
      tax1 = Taxonomy.get_by_name('tax1')
      tax1_tags = tax1.list_tags.sort
      pre_independent_kept = tax1.has_tag?('t1')
      post_independent_kept = tax1.has_tag?('t2')
      dependent_with_item_kept = tax1.has_tag?('t3')
      dependent_without_item_deleted = !tax1.has_tag?('t4')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq("1 of 1 items \"itm1\" found and deleted from album \"alm1\" of taxonomy \"tax1\"") end
      it "result data" do expect(result_data).to eq([]) end
      it "correct tags remain" do expect(tax1_tags).to eq(['t1','t2','t3']) end
      it "independent tag added before items kept" do expect(pre_independent_kept).to be_truthy end
      it "independent tag added after items kept" do expect(post_independent_kept).to be_truthy end
      it "dependent tag with items kept" do expect(dependent_with_item_kept).to be_truthy end
      it "dependent tag without items deleted" do expect(dependent_without_item_deleted).to be_truthy end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('','alm1','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items(nil,'alm1','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax2','alm1','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm1" of taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax1','','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax1',nil,'itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "nil:NilClass" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm2','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm1" from album "alm2" of taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item list missing - empty' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "" from album "alm1" of taxonomy "tax1" failed: item list missing') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item list missing - nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "nil:NilClass" from album "alm1" of taxonomy "tax1" failed: item list missing') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'no listed items found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result_code,result_msg,*result_data = face.delete_items('tax1','alm1','itm3,itm4')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('delete_items "itm3,itm4" from album "alm1" of taxonomy "tax1" failed: no listed items found') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :rename_item do
    describe 'rename valid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm2')
      it "result_code" do expect(result_code).to eq(0) end
      it "result message" do expect(result_msg).to eq('Item renamed from "itm1" to "itm2" in album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('','alm1','itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item(nil,'alm1','itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax2','alm1','itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "tax2" failed: taxonomy "tax2" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','','itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1',nil,'itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "nil:NilClass" of taxonomy "tax1" failed: album unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'album not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm2','itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm2" of taxonomy "tax1" failed: album "alm2" not found in taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "" to "itm2" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1',nil,'itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "nil:NilClass" to "itm2" in album "alm1" of taxonomy "tax1" failed: item unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'item not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm" to "itm2" in album "alm1" of taxonomy "tax1" failed: item "itm" not found in album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "" in album "alm1" of taxonomy "tax1" failed: item rename unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename nil' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1',nil)
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "nil:NilClass" in album "alm1" of taxonomy "tax1" failed: item rename unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename unchanged' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm1" in album "alm1" of taxonomy "tax1" failed: item rename unchanged') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename taken' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      face.add_item('tax1','alm1','itm2\ncontent2')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm2')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm2" in album "alm1" of taxonomy "tax1" failed: item "itm2" name taken by album "alm1" of taxonomy "tax1"') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'rename invalid' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      face.add_album('tax1','alm1')
      face.add_item('tax1','alm1','itm1\ncontent1')
      result_code,result_msg,*result_data = face.rename_item('tax1','alm1','itm1','itm%')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('rename_item "itm1" to "itm%" in album "alm1" of taxonomy "tax1" failed: item "itm%" invalid - use alphanumeric and _ characters only') end
      it "result data" do expect(result_data).to eq([]) end
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
describe Tag do
  describe :add_tags do
    describe 'tags added' do
      describe '"t1" 1 tag' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','t1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 tag and no links added to taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '"tag1>tag2,tag3" 3 tags, 1 link, 1 root, 1 folk' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','tag1>tag2,tag3')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tag_count = tax1.count_tags
        tax1_tags = tax1.list_tags.sort
        tax1_root_count = tax1.count_roots
        tax1_roots = tax1.list_roots.sort
        tax1_folk_count = tax1.count_folksonomies
        tax1_folks = tax1.list_folksonomies.sort
        face.add_taxonomy('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('3 tags and 1 link added to taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "tax1 tag count OK" do expect(tax1_tag_count).to eq(3) end
        it "tax1 root count OK" do expect(tax1_root_count).to eq(1) end
        it "tax1 folk count OK" do expect(tax1_folk_count).to eq(1) end
        it "tax1 coorect tags added" do expect(tax1_tags).to eq(['tag1','tag2','tag3']) end
        it "tax1 correct roots added" do expect(tax1_roots).to eq(['tag1']) end
        it "tax1 correct folks added" do expect(tax1_folks).to eq(['tag3']) end
      end
      describe '"tag3,tag1>tag2" 3 tags, 1 link, 1 root, 1 folk with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        result_code,result_msg,*result_data = face.add_tags('tax1','tag3,tag1>tag2',true)
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tag_count = tax1.count_tags
        tax1_tags = tax1.list_tags.sort
        tax1_root_count = tax1.count_roots
        tax1_roots = tax1.list_roots.sort
        tax1_folk_count = tax1.count_folksonomies
        tax1_folks = tax1.list_folksonomies.sort
        face.add_taxonomy('tax2')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("tag \"tag1\" added\ntag \"tag2\" added\ntag \"tag3\" added\n3 tags and 1 link added to taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "tax1 tag count OK" do expect(tax1_tag_count).to eq(3) end
        it "tax1 root count OK" do expect(tax1_root_count).to eq(1) end
        it "tax1 folk count OK" do expect(tax1_folk_count).to eq(1) end
        it "tax1 coorect tags added" do expect(tax1_tags).to eq(['tag1','tag2','tag3']) end
        it "tax1 correct roots added" do expect(tax1_roots).to eq(['tag1']) end
        it "tax1 correct folks added" do expect(tax1_folks).to eq(['tag3']) end
      end
    end
    describe 'taxonomy unspecified' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_tags('','t1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_tags "t1" to taxonomy "" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy nil' do
      Tagm8Db.wipe
      face = Facade.instance
      result_code,result_msg,*result_data = face.add_tags(nil,'t1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_tags "t1" to taxonomy "nil:NilClass" failed: taxonomy unspecified') end
      it "result data" do expect(result_data).to eq([]) end
    end
    describe 'taxonomy not found' do
      Tagm8Db.wipe
      face = Facade.instance
      face.add_taxonomy('tax1')
      result_code,result_msg,*result_data = face.add_tags('tax','t1')
      it "result_code" do expect(result_code).to eq(1) end
      it "result message" do expect(result_msg).to eq('add_tags "t1" to taxonomy "tax" failed: taxonomy "tax" not found') end
      it "result data" do expect(result_data).to eq([]) end
    end
  end
  describe :delete_tags do
    describe 'tags deleted' do
      describe '+ t1: - t1' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1')
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 1 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
      end
      describe '+ t1>t2>t3,t4: - t2,t4' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2>t3,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2,t4')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('2 of 2 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "[t1,t3] tags remain" do expect(tax1_tags).to eq(['t1','t3']) end
        it "[t1] roots remain" do expect(tax1_roots).to eq(['t1']) end
        it "[] folks remain" do expect(tax1_folks).to eq([]) end
      end
      describe '+ t1>t2>t3,t4: - t2,t4 with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2>t3,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2,t4,t5',nil,true)
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("tag \"t2\" deleted\ntag \"t4\" deleted\n2 of 3 supplied tags found and deleted from taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "[t1,t3] tags remain" do expect(tax1_tags).to eq(['t1','t3']) end
        it "[t1] roots remain" do expect(tax1_roots).to eq(['t1']) end
        it "[] folks remain" do expect(tax1_folks).to eq([]) end
      end
      describe '+ t1>t2>t3,t4: - t2,t4 branch with details' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2>t3,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2,t4,t5',true,true)
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq("tag \"t2\" deleted\ntag \"t3\" deleted\ntag \"t4\" deleted\n2 of 3 supplied tags found, 3 deleted from taxonomy \"tax1\"") end
        it "result data" do expect(result_data).to eq([]) end
        it "[t1] tags remain" do expect(tax1_tags).to eq(['t1']) end
        it "[] roots remain" do expect(tax1_roots).to eq([]) end
        it "[t1] folks remain" do expect(tax1_folks).to eq(['t1']) end
      end
      describe '+ t1>t2,t3: - t1,t4' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2,t3')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1,t4')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "[t2,t3] tags remain" do expect(tax1_tags).to eq(['t2','t3']) end
        it "[] roots remain" do expect(tax1_roots).to eq([]) end
        it "[t2,t3] folks remain" do expect(tax1_folks).to eq(['t2','t3']) end
      end
      describe '+ t1>t2,t3 - t1,t4: -t1,t2 ' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1>t2,t3')
        face.delete_tags('tax1','t1,t4')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1,t2')
        tax1 = Taxonomy.get_by_name('tax1')
        tax1_tags = tax1.list_tags.sort
        tax1_roots = tax1.list_roots.sort
        tax1_folks = tax1.list_folksonomies.sort
        it "result_code" do expect(result_code).to eq(0) end
        it "result message" do expect(result_msg).to eq('1 of 2 supplied tags found and deleted from taxonomy "tax1"') end
        it "result data" do expect(result_data).to eq([]) end
        it "t3 tags remain" do expect(tax1_tags).to eq(['t3']) end
        it "[] roots remain" do expect(tax1_roots).to eq([]) end
        it "[t3] folks remain" do expect(tax1_folks).to eq(['t3']) end
      end
    end
    describe 'delete_tags failed' do
      describe 'taxonomy unspecified' do
        describe 'other taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy nil' do
        describe 'other taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags(nil,'t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags(nil,'t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "nil:NilClass" failed: taxonomy unspecified') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'taxonomy not found' do
        describe 'other taxonomy and tags exist' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax2')
        face.add_tags('tax2','t1')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t1')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "tax1" failed: taxonomy "tax1" not found') end
        it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags('tax1','t1')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "t1" from taxonomy "tax1" failed: taxonomy "tax1" not found') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'tag syntax missing - empty' do
        describe 'taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('tax1','')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'no taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags('tax1','')
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'tag syntax missing - nil' do
        describe 'taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          face.add_taxonomy('tax1')
          face.add_tags('tax1','t1')
          result_code,result_msg,*result_data = face.delete_tags('tax1',nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "nil:NilClass" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
        describe 'taxonomy and tags exist' do
          Tagm8Db.wipe
          face = Facade.instance
          result_code,result_msg,*result_data = face.delete_tags('tax1',nil)
          it "result_code" do expect(result_code).to eq(1) end
          it "result message" do expect(result_msg).to eq('delete_tags "nil:NilClass" from taxonomy "tax1" failed: tag syntax missing') end
          it "result data" do expect(result_data).to eq([]) end
        end
      end
      describe 'no suuplied tags found' do
        Tagm8Db.wipe
        face = Facade.instance
        face.add_taxonomy('tax1')
        face.add_tags('tax1','t1')
        result_code,result_msg,*result_data = face.delete_tags('tax1','t2')
        it "result_code" do expect(result_code).to eq(1) end
        it "result message" do expect(result_msg).to eq('delete_tags "t2" from taxonomy "tax1" failed: no supplied tags found') end
        it "result data" do expect(result_data).to eq([]) end
      end
    end
  end
end



