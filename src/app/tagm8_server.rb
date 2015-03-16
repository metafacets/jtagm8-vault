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
      [0,"Taxonomy \"#{taxonomy_name}\" added",'']
    rescue => e
      [1,"Taxonomy \"#{taxonomy_name}\" not added: #{e}"]
    end
  end

  def delete_taxonomies(list)
    begin
      list = list.gsub(/\s/,'').split(',')
      bad = list.map{|name| name unless Taxonomy.exist?(name)}.join(', ')
      raise "Taxonomies \"#{bad}\" not found" unless bad.empty?
      Taxonomy.delete_taxonomies(list)
      [0,"#{list.size} taxonomies deleted"]
    rescue => e
      [1,"No taxonomies deleted: #{e}"]
    end
  end

  def list_taxonomies(sort)
    begin
      c = Taxonomy.count
      raise "No taxonomies found" if c < 1
      res = Taxonomy.list
      res.sort! if sort == 'asc'
      res.sort!.reverse! if sort == 'desc'
      [0,"#{c} taxonomies found"] + res
    rescue => e
      [1,e]
    end
  end

  def count_taxonomies
    [0,'',Taxonomy.count]
  end

  def has_taxonomy?(name)
    [0,'',Taxonomy.exists?(name)]
  end

  def add_tags(taxonomy_name,tag_syntax)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "syntax missing" if tag_syntax.nil? || tag_syntax.empty?
      Taxonomy.lazy(taxonomy_name).instantiate(tag_syntax)
      [0,"Tags \"#{tag_syntax}\" added"]
    rescue => e
      [1,"Tags not added: #{e}"]
    end
  end

  def delete_tags(taxonomy_name,list)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.lazy(taxonomy_name)
      list = list.gsub(/\s/,'').split(',')
      bad = list.map{|name| name unless tax.has_tag?(name)}.join(', ')
      raise "Tags \"#{bad}\" not found" unless bad.empty?
      tax.deprecate(list.map{|name| tax.get_lazy_tag(name)})
      [0,"#{list.size} taxonomies deleted"]
    rescue => e
      [1,"No taxonomies deleted: #{e}"]
    end
  end

  def list_tags(taxonomy_name,sort)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      res = Taxonomy.lazy(taxonomy_name).list_tags
      res.sort! if sort == 'asc'
      res.sort!.reverse! if sort == 'desc'
      res.empty? ? msg = "No tags found" : msg = "#{res.size} tags found"
      [0,msg] + res
    rescue => e
      [1,e]
    end
  end

  def ancestors(taxonomy_name,list)
    # get list of ancestors by name common to a list of tags
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.lazy(taxonomy_name)
      list = list.gsub(/\s/,'').split(',')
      list.size > 1 ? common = 'common ' : common = ''
      bad = list.map{|name| name unless tax.has_tag?(name)}.join(', ')
      raise "Tags \"#{bad}\" not found" unless bad.empty?
      # get [[tag1_ancestors],..[tagn_ancestor]]
      ancestors = list.map{|name| tax.get_lazy_tag(name).get_ancestors}
      # get [[tag1_ancestors]&[..]&[tagn_ancestor]]
      ancestors = ancestors.inject(:&)
      # get [common_ancestor_names]
      res = ancestors.map{|ancestor| ancestor.name}
      res.empty? ? msg = "No #{common}ancestors found" : msg = "#{res.size} #{common}ancestors found"
      [0,msg] + res
    rescue => e
      [1,"Getting ancestors aborted: #{e}"]
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

def add_album(album_name,taxonomy_name,dag='prevent')
    Album.new(album_name,Taxonomy.lazy(taxonomy_name,dag)) if !Album.exists?(album_name) && Taxonomy.exists?(taxonomy_name)
  end

  def list_all_albums
    Album.list
  end

  def count_all_albums
    Album.count
  end

  def list_albums(taxonomy_name=nil)
    taxonomy.nil? ? Album.list_albums : Taxonomy.lazy(taxonomy_name).list_albums if Taxonomy.exists?(taxonomy_name)
  end
  def count_albums(taxonomy_name=nil)
    taxonomy.nil? ? Album.count_albums : Taxonomy.lazy(taxonomy_name).count_albums if Taxonomy.exists?(taxonomy_name)
  end

Tagm8Db.open('tagm8-app')
DRb.start_service('druby://127.0.0.1:61671',Facade.instance)
puts 'Listening for connection'
DRb.thread.join


