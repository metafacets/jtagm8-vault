require_relative 'debug'
require_relative 'tag'
require_relative '../../src/model/mongo_mapper-db'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Album < PAlbum

  def self.exists?(name=nil)
    name.nil? ? self.count > 0 : self.count_by_name(name) > 0
  end

  # create new or open existing album by name
  # postpone - needs to pass a loaded taxonomy for new album
  #def self.lazy(name)
  #  alm = self.open(name)
  #  alm = self.new(name) if alm.nil?
  #  alm
  #end

  def initialize(name,taxonomy)
    super(name:name,taxonomy:taxonomy)
    save
  end

  def rename(name)
    self.name = name
    save
  end

  def add_item(entry=nil)
    unless !entry.is_a? String || entry.nil? || entry.empty?
      Item.new(self).instantiate(entry)
    else
      nil
    end
  end

  def delete_items(item_list)
    found = list_items&item_list
    found.each do |item_name|
      item = get_item_by_name(item_name)
      item.tags.each{|tag| tag.subtract_items([self])}
      item.delete
    end
    save
  end

  def has_item?(name=nil) count_items(name) > 0 end

  def query_items(query)
    taxonomy.query_items(query)&items
  end

end

class Item < PItem

  def self.exists?(name=nil)
    name.nil? ? self.count > 0 : self.count_by_name(name) > 0
  end

  def initialize(album)
    super(date:Time.now,album:album)
  end

  def rename(name)
    self.name = name
    self.save
  end

  def instantiate(entry)
    parse(entry)
    self
  end

  def get_taxonomy
    album.taxonomy
  end

  def parse(entry)
    parse_entry(entry)
    parse_content
    save
  end

  def parse_entry(entry)
    # gets @name and @content
    first, *rest = entry.split("\n")
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['first',first],['rest',rest]])
    self.name = first if first
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['name',name],['rest',rest]])
    if rest
      self.original_content = rest.join("\n")
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['original_content',original_content]])
    end
  end

  def parse_content
    # gets content tags
    # + or - solely instantiate or deprecate the taxonomy
    # otherwise taxonomy gets instantiated and item gets tagged by its leaves
    unless original_content.empty?
      supplied_ddl = []
      supplied_tags = []
      original_content.scan(/([+|\-|=]?)#([^\s]+)/).each do |op,tag_ddl|
        unless supplied_ddl.include?(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'1',vars:[['op',op],['tag_ddl',tag_ddl]])
          if op == '-'
            leaves,supplied = get_taxonomy.exstantiate(tag_ddl)
            self.tags -= leaves
            Debug.show(class:self.class,method:__method__,note:'2a',vars:[['tags',tags],['get_taxonomy.tags',get_taxonomy.tags]])
          else
            leaves,supplied = get_taxonomy.instantiate(tag_ddl)
            Debug.show(class:self.class,method:__method__,note:'2',vars:[['leaves',leaves]])
            if op == '' || op == "="
              leaves.each {|tag| tag.union_items([self])}
              self.tags << leaves
              Debug.show(class:self.class,method:__method__,note:'2b',vars:[['tags',tags],['get_taxonomy.tags',get_taxonomy.tags]])
            end
          end
          supplied_ddl << tag_ddl
          supplied_tags |= supplied
        end
      end
      set_original_tag_ids(supplied_tags)
    end
  end

  def set_original_tag_ids(supplied_tags)
    self.original_tag_ids = supplied_tags.map{|tag| [tag.name,tag._id.to_s] unless tag.nil?}.select{|tag| tag unless tag.nil?}.sort_by{|e| e[0].length}.reverse.join(',')
    #puts "Item.set_original_tag_ids: original_tag_ids=#{original_tag_ids}"
  end

  def inspect; "#{self.name}\n#{get_content}" end

  def to_s; inspect end

  def get_content
    result = original_content.dup
    #puts "Item.get_content 1: original_content=#{original_content}, original_tag_ids=#{self.original_tag_ids}"
    #puts "Item.get_content 2: tags.size=#{tags.size}, get_taxonomy.name=#{get_taxonomy.name}, get_taxonomy.count_tags=#{get_taxonomy.count_tags}, get_taxonomy.has_tag?=#{get_taxonomy.has_tag?}"
    #puts "Item.get_content 2a: tags.map{|tag| [tag.name,tag._id.to_s]}=#{tags.map{|tag| [tag.name,tag._id.to_s]}}" unless tags.empty?
    if !self.original_tag_ids.nil?
      # transform substitutions into array of paired old lowercase and new uppercase tag names including unchanged
      old_id = original_tag_ids.split(',').each_slice(2).to_a
      old_new = old_id.map{|name,id| Tag.get_by_id(id).nil? ? [name,name.upcase] : [name,Tag.get_by_id(id).name.upcase]}
#      old_new = old_id.map do |name,id|
#        if !Tag.get_by_id(id).nil?                # as it should be found with latest name
#          [name,Tag.get_by_id(id).name.upcase]
#        else                                      # try 2 alternative methods of locating partially propogated tags
#          tax_tag = get_taxonomy.get_tag_by_name(name)
#          if (!tax_tag.nil? && tax_tag._id == id) || tags.empty? || !tags.select{|tag| tag.name == name && tag._id.to_s == id}.empty?
#            puts "Item.get_content 3a: same"
#            [name,name.upcase]
#          else                                    # tag must be deleted
#            puts "Item.get_content 3a: deleted"
#            [name,"#{name}_deleted".upcase]
#          end
#        end
#      end
      #puts "Item.get_content 3: old_new=#{old_new}"
      # replace old with new tag names, old_new start with longest first with case transformation preventing nested substitutions
      tail = original_content.dup
      while tail =~ /#([^\s]+)((.|\n)*)/
        ddl,tail = $1,$2
        ddl_sub = ddl.dup
        old_new.each{|old,new| ddl_sub.gsub!(old,new)}
        #puts "Item.get_content 4: ddl=#{ddl}, tail=#{tail}, ddl_sub=#{ddl_sub}"
        result.gsub!("##{ddl}#{tail}","##{ddl_sub.downcase}#{tail}")
        #puts "Item.get_content 5: result=#{result}"
      end
    end
    result
  end

  def query_tags
    # get tags matching this item - the long way from the Taxonomy
    # used for testing
    result = []
    get_taxonomy.tags.each {|tag| result |= [tag] if tag.items.include? self}
    result
  end

end

## RECENT TESTS ##

#MongoMapper.connection.drop_database('tagm8')
#tax = Taxonomy.new(name:'MyTax')
#puts "tax=#{tax}, tax.name=#{tax.name}, tax.id=#{tax.id}"
#clx = tax.add_album('MyAlbum')
#item1 = clx.add_item("Item 1\ncontent 1")
#item2 = clx.add_item("Item 2\ncontent 2")
#puts "clx=#{clx}, clx.name=#{clx.name}, clx.id=#{clx.id}, clx.taxonomy=#{clx.taxonomy}, clx.items=#{clx.items}"
##item3 = Item.new.instantiate("Item 3\ncontent 3")
##clx.add_to_set(items:item3)
##puts "clx=#{clx}, clx.name=#{clx.name}, clx.id=#{clx.id}, clx.taxonomy=#{clx.taxonomy}, clx.items=#{clx.items}"
#puts "item1=#{item1}, date=#{item1.date}, name=#{item1.name}, content=#{item1.content}, album=#{item1.album}, album.name=#{item1.album.name}, taxonomy=#{item1.album.taxonomy}"

## ORIGINAL TESTS ##

#tax.instantiate('[:cat,:dog]<:mammal')
#puts "tax.tags=#{tax.tags}"
#item4 = clx.add_item("Item 4\n+#[mammal,fish]<:animal>[insect,bird>[parrot,eagle]]\nMy entry =#cat,fish #:dog for my cat and dog")
#puts "item=#{item4}, date=#{item4.date}, name=#{item4.name}, content=#{item4.content}, get_tags=#{item4.tags}"
#puts "tax.tags=#{tax.tags}"







