require_relative 'tag'
require 'drb'
require 'singleton'

class Facade
  attr_accessor :taxonomy, :album
  include Singleton
  def add_taxonomy(taxonomy_name,dag='prevent')
    begin
      raise "name taken" if Taxonomy.exists?(taxonomy_name)
      raise "dag \"#{dag}\" invalid - use prevent, fix or free" unless ['prevent','fix','free'].include?(dag)
      Taxonomy.new(taxonomy_name,dag)
      "Taxonomy \"#{taxonomy_name}\" added"
    rescue => e
      "Taxonomy \"#{taxonomy_name}\" not added: #{e}"
    end
  end
  def add_album(album_name,taxonomy_name,dag='prevent')
    Album.new(album_name,Taxonomy.lazy(taxonomy_name,dag)) if !Album.exists?(album_name) && Taxonomy.exists?(taxonomy_name)
  end
  def list_all_albums
    Album.list
  end
  def count_all_albums
    Album.count
  end
  def list_all_taxonomies
    Taxonomy.list
  end
  def count_all_taxonomies
    Taxonomy.count
  end
  def has_taxonomy?(name)
    Taxonomy.exists?(name)
  end
  def list_albums(taxonomy_name=nil)
    taxonomy.nil? ? Album.list_albums : Taxonomy.lazy(taxonomy_name).list_albums if Taxonomy.exists?(taxonomy_name)
  end
  def count_albums(taxonomy_name=nil)
    taxonomy.nil? ? Album.count_albums : Taxonomy.lazy(taxonomy_name).count_albums if Taxonomy.exists?(taxonomy_name)
  end
  def list_tags(taxonomy_name)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      Taxonomy.lazy(taxonomy_name).list_tags
    rescue => e
      e
    end
  end
  def add_tags(taxonomy_name,tag_syntax)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "syntax missing" if tag_syntax.nil? || tag_syntax.empty?
      Taxonomy.lazy(taxonomy_name).instantiate(tag_syntax)
      "Tags \"#{tag_syntax}\" added"
    rescue => e
      "Tags not added: #{e}"
    end
  end
  def delete_tags(tag_name_list)
    unless taxonomy.nil?
      tags = tag_name_list.map{|tag_name| tag = taxonomy.get_lazy_tag(tag_name) if taxonomy.has_tag?(tag_name)}
      tags.each{|tag| taxonomy.delete_tag(tag)}
    end
  end
  def ancestors(tag_names)
    # get list of ancestors by name common to a list of tags
    tag_names = [tag_names] if tag_names.class == 'String'
    unless tag_names.class != 'List' || taxonomy.nil?
      # get [[tag1_ancestors],..[tagn_ancestor]]
      ancestors = tag.names.map{|tag_name| taxonomy.get_tag(tag_name).get_ancestors if taxonomy.has_tag?(tag_name)}
      # get [[tag1_ancestors]&[..]&[tagn_ancestor]]
      ancestors = ancestors.inject(:&)
      # get [common_ancestor_names]
      ancestors.map{|ancestor| ancestor.name}
    else
      []
    end
  end
  def descendents(tag_name)
    # to-do support tag-name-list
    unless taxonomy.nil?
      unless taxonomy.has_tag?(tag_name)
        taxonomy.get_tag(tag_name).get_descendents
      end
    end
  end

end

Tagm8Db.open('tagm8-app')
DRb.start_service('druby://127.0.0.1:61672',Facade.instance)
puts 'Listening for connection'
DRb.thread.join


