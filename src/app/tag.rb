require_relative 'debug'
require_relative 'ddl'
require_relative 'query'
require_relative 'item'
require_relative '../../src/model/mongo_mapper-db'
#require 'singleton'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Taxonomy < PTaxonomy

  def self.exists?(name=nil)
    name.nil? ? self.count > 0 : self.count_by_name(name) > 0
  end

  # create new or open existing taxonomy by name
  def self.lazy(name,dag='prevent')
    tax = self.get_by_name(name)
    tax = self.new(name,dag) if tax.nil?
    tax
  end

  def self.delete_taxonimies(list)
    list.each{|name| self.get_by_name(name).delete}
  end

  def count_links
    link_count = 0
    roots.each{|root| link_count += root.count_links}
    link_count
#    roots.inject{|link_count,root| link_count + root.count_links}
  end

  def initialize(name='taxonomy',dag='prevent')
    super(name:name,dag:dag)
    save
  end

  def empty?; !has_tag? && !has_root? && !has_folksonomy? end

  def show(item) eval(item) end

  def dag?; self.dag != 'false' end
  def set_dag(dag)
    self.dag = dag if ['prevent','fix','false'].include?(dag)
    save
  end

  def rename(name)
    self.name = name
    save
  end

  def delete_tag(name)
    # joins parents to children of deleted tag
    if has_tag?(name)
      #puts "Taxonomy.delete_tag: name=#{name}"
      tag = get_tag_by_name(name)
      #puts "Taxonomy.delete_tag: tag=#{tag}"
      parents = tag.get_parents
      children = tag.get_children
      #puts "Taxonomy.delete_tag: parents=#{parents}, children=#{children}"
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['tag',tag],['parents',parents],['children',children]])
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['tags',tags],['roots',roots],['folks',folksonomy]])
      parents.each do |parent|
        parent.subtract_children([tag])
        #parent.children -= [tag]
        parent.union_children(children)
        #parent.children |= children
      end
      children.each do |child|
        child.subtract_parents([tag])
        #child.parents -= [tag]
        child.union_parents(parents)
        #child.parents |= parents
      end
      tag.items.each {|item| item.tags -= [tag]; item.save;}
      #puts "Taxonomy.delete_tag: tag_count=#{tag_count}, tags=#{tags}"
      subtract_tags([tag])
      #puts "Taxonomy.delete_tag: tag_count=#{tag_count}, tags=#{tags}"
      #puts "Taxonomy.delete_tag: parents=#{parents}"
      #puts "Taxonomy.delete_tag: children=#{children}"
      #subtract_roots([tag])
      #subtract_folksonomies([tag])
      #puts "Taxonomy.delete_tag: parents|children=#{parents|children}"
      update_status(parents|children)
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['tags',tags],['roots',roots],['folks',folksonomy]])
    end
  end

  def instantiate(tag_ddl)
    leaves = []
    Ddl.parse(tag_ddl)
    if Ddl.has_tags?
      tags = Ddl.tags.map {|name| get_lazy_tag(name)}
      leaves = Ddl.leaves.map {|name| get_lazy_tag(name)}
      Ddl.links.each do |pair|
        [0,1].each do |i|
          pair[i] = pair[i].map {|name| get_lazy_tag(name)}
        end
        link(pair[0],pair[1],false)
      end
      update_status(tags)
    end
    [leaves,tags]
  end

  def exstantiate(tag_ddl,branch=false,report=false)
    Ddl.parse(tag_ddl)
    found = Ddl.tags.map {|name| get_tag_by_name(name)}.select{|tag| tag unless tag.nil?}
    before = tags
    before_list = list_tags if report
    branch ? found.each{|tag| tag.delete_branch} : found.each {|tag| delete_tag(tag.name)}
    deleted = tags-before
    # [supplied_count,found_count,deleted_count,deleted_tags,deleted_list]
    report ? [Ddl.tags.size,found.size,deleted.size,list_tags-before_list] : [deleted,found]
  end

  def query_items(query)
    Query.taxonomy = self
    begin
      eval(Query.parse(query))
    rescue SyntaxError
      []
    end
  end

  def has_tag?(name=nil) count_tags(name) > 0 end

  def add_tags(names_children, name_parent=nil)
    children = names_children.map {|name| get_lazy_tag(name)}.uniq
    link(children,[get_lazy_tag(name_parent)]) unless name_parent.nil?
  end

  def add_tag(name, name_parent=nil) add_tags([name],name_parent) end

  def get_lazy_tag(node)
    case
      when node.class == 'Tag'
        node
      when has_tag?(node)
        get_tag_by_name(node)
      else
        Tag.new(node,self)
    end
  end

  # def roots; @roots end

  # def folksonomy; @folksonomy end

  def update_status(tags)
    this_status = lambda {|tag|
      #puts "PTaxonomy.update_status: tag=#{tag}, tag.has_parent?=#{tag.has_parent?}, tag.has_child?=#{tag.has_child?}"
      if tag.has_parent?
        tag.register_offspring
      else
        if tag.has_child?
          tag.register_root
        else
          tag.register_folksonomy
        end
      end
    }
    tags.each {|tag| this_status.call(tag)}
  end

  def link(children,parents,status=true)
    link_children = lambda {|children,parent|
      #puts "Taxonomy.link.link_children: parent=#{parent}"
      children -= [parent]
      unless children.empty?
        ctags = children.clone
        ancestors = parent.get_ancestors if dag?
        children.each do |child|
          Debug.show(class:self.class,method:__method__,note:'1',vars:[['name',child.name],['parent',name]])
          if dag? && ancestors.include?(child)
            #puts "Taxonomy.link.link_children: child=#{child}, ancestors=#{ancestors}, dag_prevent?=#{dag_prevent?}"
            if dag == 'prevent'
              ctags -= [child]
            else
              (parent.get_parents & child.get_descendents+[child]).each {|grand_parent| parent.delete_parent(grand_parent)}
              child.union_parents([parent])
              #child.parents |= [parent]
            end
          else
            child.union_parents([parent])
            #child.parents |= [parent]
          end
        end
        parent.union_children(ctags)
        #parent.children |= ctags
      end
    }
    parents = parents.uniq
    children = children.uniq
    #puts "Taxonomy.link: parents=#{parents}, children=#{children}"
    parents.each {|parent| link_children.call(children,parent)}
    update_status(parents|children) if status
  end

  def add_album(name)
    Album.new(name,self)
  end

  def delete_albums(album_list)
    found = list_albums&album_list
    found.each do |album_name|
      album = get_album_by_name(album_name)
      album.delete_items(album.list_items)
      album.delete
    end
  end

  def has_album?(name=nil) count_albums(name) > 0 end

end

class Tag < PTag
  def self.exists?(name=nil)
    name.nil? ? self.count > 0 : self.count_by_name(name) > 0
  end

  def initialize(name,tax)
    super(name:name,is_root:false,is_folk:true,taxonomy:tax._id)
    save
  end

  def rename(name)
    self.name = name
    save
  end

  def delete_parent(parent)
    #puts "Tag.delete_parent: self=#{self}, parent=#{parent}"
    parent.delete_child(self)
  end

  def create_parents(parents); get_taxonomy.link([self],parents) end

  def create_children(children); get_taxonomy.link(children,[self]) end

  def empty_children; @children = [] end

  def get_ancestors(ancestors=[])
    #puts "Tag.get_ancestors: ancestors=#{ancestors}"
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['self',self],['ancestors',ancestors]])
    parnts = get_parents
    parnts.each {|parent| ancestors |= parent.get_ancestors(parnts)}
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['ancestors',ancestors]])
    ancestors
  end

  def get_depth(root,branch)
    # walks up branch from self to root returning depth
    # dag support requirs nodes outside branch are ignored
    if get_parents.include?(root)
      depth = 1
    else
      parent = (get_parents & branch).pop
      parent.nil? ? depth = 0 : depth = parent.get_depth(root,branch) + 1
    end
    depth
  end

  def get_descendents
    descendents,_ = collate_descendents
    descendents
  end

  def count_links
    _,link_count = collate_descendents
    link_count
  end

  def collate_descendents(descendents=[])
#    puts "Tag.get_descendents: descendents=#{descendents}"
    childs = get_children
    link_count = childs.size
#    puts "Tag.get_descendents: childs=#{childs}"
    childs.each do |child|
      child_descendents,child_link_count = child.collate_descendents(childs)
      descendents |= child_descendents
      link_count += child_link_count
    end
    [descendents,link_count]
  end

  def delete_descendents
#    puts "Tag.delete_descendents: self=#{self}"
    descendents = get_descendents
#    puts "Tag.delete_descendents: descendents=#{descendents}"
    tax = get_taxonomy
    tax.subtract_tags(descendents)
    tax.subtract_roots(descendents)
    tax.subtract_folksonomies(descendents)
    empty_children
  end

  def add_descendents(children) create_children(children) end

  def delete_branch
    # delete self and its descendents
    delete_descendents
#    puts "Tag.delete_branch 1"
    get_parents.each{|parent| parent.delete_child(self)}
#    puts "Tag.delete_branch 2"
    get_taxonomy.subtract_tags([self])
  end

  def add_branch(tag)
    # if self is root add tag as new root else add tag as sibling of self
  end

  def query_items
    # queries items matching this tag
    result = items
    get_descendents.each {|desc| result |= desc.items}
    result
  end

  def inspect
    items.empty? ? pretty_items = '' : pretty_items = ", items=#{items.map {|item| item.name}}"
    "Tag<#{name}: parents=#{taxonomy.list_tags_by_id(parents)}, children=#{taxonomy.list_tags_by_id(children)}#{pretty_items}>"
  end
  def to_s; inspect end

  # methods added for rspec readability
  def folk?; !has_parent? && !has_child? end
  def root?; !has_parent? && has_child? end

end

