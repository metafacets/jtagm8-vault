require_relative 'tag'
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

  def delete_taxonomies(list,details=false)
    begin
      raise "list missing" if list.empty?
      list = list.gsub(/\s/,'').split(',')
      found = list.map{|name| name if Taxonomy.exist?(name)}
      initial = Taxonomy.list
      Taxonomy.delete_taxonomies(found)
      deleted = initial-Taxonomy.list
      msg = ''
      deleted.each{|name| msg += "Taxonomy \"#{name}\" deleted\n"} if details
      found.size == deleted.size ? insert = ' and' : insert = ", #{deleted.size}"
      [0,"#{msg}#{found.size} of #{list.size} supplied taxonomies found#{insert} deleted"]
    rescue => e
      [1,"No taxonomies deleted: #{e}"]
    end
  end

  def list_taxonomies(reverse=false,details=false)
    begin
      c = Taxonomy.count
      raise "No taxonomies found" if c < 1
      res = Taxonomy.list.sort
      res.reverse! if reverse
      if details
        longest = res.group_by(&:size).max.last.last.size
        res.each_with_index do |name,i|
          tax = Taxonomy.get_by_name(name)
          if i%10 > 0
            res[i] = "%-#{longest}s %-8s %3s      %2s       %3s       %2s       " % [name,tax.dag,tax.count_tags,tax.count_roots,tax.count_folksonomies,tax.count_albums]
          else
            res[i] = "%-#{longest}s %-8s %3s tags %2s roots %3s folks %2s albums" % [name,tax.dag,tax.count_tags,tax.count_roots,tax.count_folksonomies,tax.count_albums]
          end
        end
      end
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

  def dag?(taxonomy_name)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.lazy(taxonomy_name).dag]
    rescue => e
    [1,e]
    end
  end

  def dag_set(taxonomy_name,dag)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "set_dag(#{dag}) invalid dag value" unless ['prevent','fix','false'].include?(dag)
      tax = Taxonomy.lazy(taxonomy_name)
      tax.set_dag(dag)
      confirmed = tax.dag
      raise "dag = #{confirmed}" if confirmed != dag
      [0,"dag_#{dag} confirmed"]
    rescue => e
      [1,"dag_#{dag} unsuccessful: #{e}"]
    end
  end

  def add_tags(taxonomy_name,tag_syntax)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "syntax missing" if tag_syntax.empty?
      Taxonomy.lazy(taxonomy_name).instantiate(tag_syntax)
      [0,"Tags \"#{tag_syntax}\" added"]
    rescue => e
      [1,"Tags not added: #{e}"]
    end
  end

  def delete_tags(taxonomy_name,tag_list,branch=false,details=false)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "list missing" if tag_list.empty?
      tax = Taxonomy.lazy(taxonomy_name)
      list = list.gsub(/\s/,'').split(',')
      found = list.map{|name| name if tax.has_tag?(name)}
      initial = tax.list_tags
      tax.deprecate(found,branch)
      deleted = initial-tax.list_tags
      msg = ''
      deleted.each{|tag| msg += "Tag \"#{tag}\" deleted\n"} if details
      found.size == deleted.size ? insert = ' and' : insert = ", #{deleted.size}"
      [0,"#{msg}#{found.size} of #{list.size} supplied tags found#{insert} deleted"]
    rescue => e
      [1,"Tags not deleted: #{e}"]
    end
  end

  def list_tags(taxonomy_name,reverse=false,hierarchy=false)
    begin
      show_nested = lambda{|taxonomy,tag_name,reverse,depth=0|
        indent = '   '*depth if depth > 0
        tree = ["#{indent}#{tag_name}\n"]
        list_children = taxonomy.get_tag_by_name(tag_name).get_children.map{|child| child.name}.sort
        list_children.reverse! if reverse
        list_children.each{|child_name| tree += show_nested.call(taxonomy,child_name,reverse,depth+1)}
        tree
      }
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.lazy(taxonomy_name)
      unless tax.empty?
        res = []
        tags_count = tax.count_tags
        roots_count = tax.count_roots
        folks_count = tax.count_folksonomies
        if hierarchy
          if roots_count > 0
            roots_count > 1 ? h_insert = 'ies' : h_insert = 'y'
            tags_count-folks_count > 1 ? t_insert = 's' : t_insert = ''
            roots = tax.roots.map{|tag| tag.name}.sort!
            roots.reverse! if reverse
            roots.each{|root_name| res += show_nested.call(tax,root_name,reverse)}
            msg = "#{roots_count} hierarch#{h_insert} found containing #{tags_count-folks_count} tag#{t_insert}\n"
          else
            msg = "No tag hierarchies found\n"
          end
          if folks_count > 0
            folks_count > 1 ? t_insert = 's' : t_insert = ''
            folks = tax.folksonomies.map{|tag| tag.name}.sort!
            folks.reverse! if reverse
            res += folks
            msg += "#{folks_count} folksonomy tag#{t_insert} found\n"
          else
            msg += "No folksonomy tags found\n"
          end
        else
          res = tax.list_tags.sort!
          res.reverse! if reverse
        end
        tags_count > 1 ? t_insert = 's' : t_insert = ''
        msg += "#{tags_count} tag#{t_insert} found in total"
      else
        msg = "No tags found"
      end
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
end
