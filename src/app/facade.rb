require_relative 'tag'
require 'singleton'

class Facade
  attr_accessor :taxonomy, :album
  include Singleton

  def name_ok?(name) name =~ /\A\p{Alnum}+\z/ end

  def add_taxonomy(taxonomy_name,dag='prevent')
    begin
      raise "name taken" if Taxonomy.exists?(taxonomy_name)
      raise "dag \"#{dag}\" invalid - use prevent, fix or free" unless ['prevent','fix','free'].include?(dag)
      Taxonomy.new(taxonomy_name,dag)
      [0,"Taxonomy \"#{taxonomy_name}\" added",'']
    rescue => e
      [1,"add_taxonomy \"#{taxonomy_name}\" aborted: #{e}"]
    end
  end

  def rename_taxonomy(taxonomy_name,new_name)
    begin
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "taxonomy \"#{new_name}\" invalid - use alphanumeric characters only" unless name_ok?(new_name)
      tax = Taxonomy.lazy(taxonomy_name)
      tax.rename(new_name)
      raise "name is \"#{tax.name}\"" unless tax.name == new_name
      [0,"Taxonomy\"#{taxonomy_name}\" renamed to \"#{new_name}\"",'']
    rescue => e
      [1,"rename_taxonomy \"#{taxonomy_name}\" failed: #{e}"]
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
      raise "No taxonomies deleted" if deleted.empty?
      msg = ''
      deleted.each{|name| msg += "Taxonomy \"#{name}\" deleted\n"} if details
      remaining = (Taxonomy.list & found).map{|name| "\"#{name}\""}
      remaining.empty? ? remaining_insert = '' : remaining_insert = ", #{remaining.join(', ')} not deleted"
      found.size == deleted.size ? insert = ' and' : insert = ", #{deleted.size}"
      [0,"#{msg}#{found.size} of #{list.size} supplied taxonomies found#{insert} deleted#{remaining_insert}"]
    rescue => e
      [1,"delete_taxonomies failed: #{e}"]
    end
  end

  def list_taxonomies(reverse=false,details=false)
    begin
      c = Taxonomy.count
      raise "No taxonomies found" if c < 1
      res = Taxonomy.list.sort
      res.reverse! if reverse
      if details
        longest = res.max_by(&:length).size
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
      [1,"list_taxonomies failed: #{e}"]
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
      [1,"dag_#{dag} failed: #{e}"]
    end
  end

  def add_tags(taxonomy_name,tag_syntax)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "syntax missing" if tag_syntax.empty?
      Taxonomy.lazy(taxonomy_name).instantiate(tag_syntax)
      [0,"Tags \"#{tag_syntax}\" added"]
    rescue => e
      [1,"add_tags failed: #{e}"]
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
      [1,"delete_tags failed: #{e}"]
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
      [1,"list_tags failed: #{e}"]
    end
  end

  def count_tags(taxonomy_name)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.lazy(taxonomy_name).count_tags]
    rescue => e
      [1,"count_tags failed: #{e}"]
    end
  end

  def list_genealogy(genealogy,taxonomy_name,list,reverse=false)
    # supports list_ancestors and list_descendents
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.lazy(taxonomy_name)
      list = list.gsub(/\s/,'').split(',')
      list.size > 1 ? common = 'common ' : common = ''
      bad = list.select{|name| name unless tax.has_tag?(name)}
      unless bad.empty?
        bad.size > 1 ? insert = 's' : insert = ''
        raise "Tag#{insert} \"#{bad.join(', ')}\" not found"
      end
      # get [[tag1_relatives],..[tagn_relatives]]
      relatives = list.map{|name| tax.get_lazy_tag(name).send("get_#{genealogy}")}
      # get [[tag1_relatives]&[..]&[tagn_relatives]]
      relatives = relatives.inject(:&)
      # get [common_relative_names]
      res = relatives.map{|relative| relative.name}.sort!
      res.reverse! if reverse
      res.size > 1 ? insert = 's' : insert = ''
      res.empty? ? msg = "No #{common}#{genealogy} found" : msg = "#{res.size} #{common}#{genealogy[0...-1]}#{insert} found"
      [0,msg] + res
    rescue => e
      [1,"list_#{genealogy} failed: #{e}"]
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
