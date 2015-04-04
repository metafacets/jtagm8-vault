require_relative 'tag'
require 'singleton'

class Facade
  attr_accessor :taxonomy, :album
  include Singleton

  def name_ok?(name) name =~ /[A-Za-z0-9_]+/ end

  def add_taxonomy(taxonomy_name,dag='prevent')
    begin
      raise "name taken" if Taxonomy.exists?(taxonomy_name)
      raise "\"#{taxonomy_name}\" invalid name - use alphanumeric characters only" unless name_ok?(taxonomy_name)
      raise "dag \"#{dag}\" invalid - use prevent, fix or free" unless ['prevent','fix','free'].include?(dag)
      Taxonomy.new(taxonomy_name,dag)
      raise "taxonomy \"#{taxonomy_name}\" remains non-existent" unless Taxonomy.exists?(taxonomy_name)
      [0,"Taxonomy \"#{taxonomy_name}\" added",'']
    rescue => e
      [1,"add_taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def rename_taxonomy(taxonomy_name,new_name)
    begin
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "\"#{new_name}\" invalid name - use alphanumeric characters only" unless name_ok?(new_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      tax.rename(new_name)
      raise "name is \"#{tax.name}\"" unless tax.name == new_name
      [0,"Taxonomy \"#{taxonomy_name}\" renamed to \"#{new_name}\""]
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
      raise "No taxonomies exist" if c < 1
      res = Taxonomy.list.sort
      res.reverse! if reverse
      if details
        longest = res.max_by(&:length).size
        res.each_with_index do |name,i|
          tax = Taxonomy.get_by_name(name)
          if i%10 > 0
            res[i] = "%-#{longest}s %-8s %3s      %2s       %3s       %5s links %2s       " % [name,tax.dag,tax.count_tags,tax.count_roots,tax.count_folksonomies,tax.count_links,tax.count_albums]
          else
            res[i] = "%-#{longest}s %-8s %3s tags %2s roots %3s folks %5s links %2s albums" % [name,tax.dag,tax.count_tags,tax.count_roots,tax.count_folksonomies,tax.count_links,tax.count_albums]
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
      [0,"Taxonomy \"#{taxonomy_name}\" dag set to #{dag}"]
    rescue => e
      [1,"dag_#{dag} failed: #{e}"]
    end
  end

  def add_tags(taxonomy_name,tag_syntax,details=false)
    begin
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "tags missing" if tag_syntax.empty?
      tax = Taxonomy.get_by_name(taxonomy_name)
      tags_before = tax.list_tags
      links_before = tax.count_links
      tax.instantiate(tag_syntax)
      tags_added = (tax.list_tags-tags_before).sort.map{|name| "\"#{name}\""}
      d_insert = ''
      tags_added.each{|name| d_insert += "Tag \"#{name}\" added"} if details
      tags_added.size > 0 ? t_insert = "#{tags_added.size} tag" : t_insert = 'no new tag'
      t_insert += 's' unless tags_added.size == 1
      links_added = tax.count_links-links_before
      links_added > 0 ? l_insert = "#{links_added} link" : l_insert = 'no new link'
      l_insert += 's' unless links_added == 1
      [0,"#{d_insert}#{t_insert} and #{l_insert} added to taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"add_tags failed: #{e}"]
    end
  end

  def delete_tags(taxonomy_name,tag_syntax,branch=false,details=false)
    begin
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "tags missing" if tag_syntax.empty?
      tax = Taxonomy.get_by_name(taxonomy_name)
      supplied,found,deleted,deleted_list = tax.exstantiate(tag_syntax,branch,true)
      d_insert = ''
      deleted_list.each{|tag| d_insert += "Tag \"#{tag}\" deleted\n"} if details
      found == deleted ? insert = ' and' : insert = ", #{deleted.size}"
      [0,"#{d_insert}#{found} of #{supplied} supplied tags found#{insert} deleted from taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"delete_tags failed: #{e}"]
    end
  end

  def rename_tag(taxonomy_name,tag_name,new_name)
    begin
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "tag \"#{tag_name}\" not found" unless tax.has_tag?(tag_name)
      raise "\"#{new_name}\" invalid name - use alphanumeric characters only" unless name_ok?(new_name)
      tag = tax.get_tag_by_name(tag_name)
      tag.rename(new_name)
      raise "name is \"#{tag.name}\"" unless tag.name == new_name
      [0,"tag \"#{tag_name}\" renamed to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"rename_tag \"#{tag_name}\" failed: #{e}"]
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
            links_count = tax.count_links
            links_count > 1 ? l_insert = 's' : l_insert = ''
            msg = "#{roots_count} hierarch#{h_insert} found containing #{tags_count-folks_count} tag#{t_insert} and #{links_count} link#{l_insert}\n"
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
          msg = ''
        end
        tags_count > 1 ? t_insert = 's' : t_insert = ''
        msg += "#{tags_count} tag#{t_insert} found in total"
      else
        msg = "No tags found"
      end
      [0,"#{msg} for taxonomy \"#{taxonomy_name}\""] + res
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

  def count_links(taxonomy_name)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.lazy(taxonomy_name).count_links]
    rescue => e
      [1,"count_links failed: #{e}"]
    end
  end

  def count_roots(taxonomy_name)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.lazy(taxonomy_name).count_roots]
    rescue => e
      [1,"count_roots failed: #{e}"]
    end
  end

  def count_folksonomies(taxonomy_name)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      [0,'',Taxonomy.lazy(taxonomy_name).count_folksonomies]
    rescue => e
      [1,"count_folksonomies failed: #{e}"]
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

  def add_album(taxonomy_name,album_name)
    begin
      raise "\"taxonomy not specified" if taxonomy_name.empty? || taxonomy_name.nil?
      raise "\"album not specified" if album_name.empty? || album_name.nil?
      raise "\"taxonomy #{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "\"#{album_name}\" name taken by taxonomy \"#{taxonomy_name}\"" if tax.has_album?(album_name)
      raise "\"#{album_name}\" invalid name - use alphanumeric characters only" unless name_ok?(album_name)
      tax.add_album(album_name)
      raise "album \"#{album_name}\" remains non-existent" unless Album.exists?(album_name)
      raise "album \"#{album_name}\" created but not added to taxonomy #{taxonomy_name}" unless tax.has_album?(album_name)
      [0,"album \"#{album_name}\" added to taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"add_album \"#{album_name}\" failed: #{e}"]
    end
  end

  def delete_albums(taxonomy_name,album_list,details=false)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "list missing" if album_list.empty?
      tax = Taxonomy.lazy(taxonomy_name)
      list = album_list.gsub(/\s/,'').split(',')
      found = tax.list_albums&list
      initial = tax.list_albums
      tax.delete_albums(found)
      deleted = initial-tax.list_albums
      msg = ''
      deleted.each{|album| msg += "Album \"#{album}\" deleted\n"} if details
      found.size == deleted.size ? insert = ' and' : insert = ", #{deleted.size}"
      [0,"#{msg}#{found.size} of #{list.size} supplied albums found#{insert} deleted using taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"delete_albums failed: #{e}"]
    end
  end

  def rename_album(taxonomy_name=nil,album_name,new_name)
    begin
      raise "\"#{new_name}\" invalid name - use alphanumeric characters only" unless name_ok?(new_name)
      if taxonomy_name.nil?
        raise "album \"#{album_name}\" not found" unless Album.exists?(album_name)
        albums = Album.get_by_name(album_name)
      else
        raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
        albums = [tax.get_album_by_name(album_name)]
      end
      supplied = albums.size
      renamed = Album.count_by_name(new_name)
      albums.each{|album| album.rename(new_name)}
      renamed = Album.count_by_name(new_name) - renamed
      raise "no albums renamed to \"#{new_name}\"" if renamed == 0
      [0,"#{renamed} of #{supplied} albums renamed from \"#{album_name}\" to \"#{new_name}\""]
    rescue => e
      [1,"rename_album \"#{album_name}\" failed: #{e}"]
    end
  end

  def list_albums(taxonomy_name=nil,album_name=nil,reverse=false,details=false)
    begin
      if taxonomy_name.nil?
        res = Album.list
        raise "No albums exist" if res.empty?
        t_insert = ' %s (taxonomy)'
        in_taxonomy = ''
      else
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        res = tax.list_albums
        t_insert = ''
        in_taxonomy = " in taxonomy \"#{taxonomy_name}\""
      end
      if album_name.nil?
        with_name = ''
      else
        res = res.select{|r| r == album_name}
        with_name = " with name \"#{album_name}\""
      end
      item_details = ''
      if res.empty?
        album_total = 'No albums'
      else
        album_total = "#{res.size} album"
        album_total += 's' unless res.size == 1
        res.sort!
        res.reverse! if reverse
        if details
          longest = res.max_by(&:length).size
          item_total = 0
          taxonomies = []
          i = 0
          res.each do |name|
            taxonomy_name.nil? ? albums = Album.get_by_name(name) : albums = [tax.get_album_by_name(name)]
            albums = albums.sort_by{|album| album.taxonomy.name}
            albums.reverse! if reverse
            albums.each do |album|
              item_count = album.count_items
              item_total += item_count
              taxonomy_name.nil? ? t_name = album.taxonomy.name : t_name = ''
              taxonomies |= [t_name]
              if i%10 > 0
                res[i] = "%-#{longest}s %4s      #{t_insert[0..2]}" % [name,item_count,t_name]
              else
                res[i] = "%-#{longest}s %4s items#{t_insert}" % [name,item_count,t_name]
              end
              i += 1
            end
          end
          item_details = " containing #{item_total} item"
          item_details += 's' unless item_total == 1
          if taxonomy_name.nil?
            in_taxonomy = " in #{taxonomies.size} taxonom"
            taxonomies.size == 1 ? in_taxonomy += 'y' : in_taxonomy += 'ies'
          end
        end
      end
      [0,"#{album_total}#{with_name} found#{in_taxonomy}#{item_details}"] + res
    rescue => e
      [1,"list_albums failed: #{e}"]
    end
  end

  def count_albums(taxonomy_name=nil,album_name=nil)
    begin
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      taxonomy_name.nil? ? res = Album.count_by_name(album_name) : res = Taxonomy.get_by_name(taxonomy_name).count_albums(album_name)
      [0,'',res]
    rescue => e
      [1,"count_tags failed: #{e}"]
    end
  end

  def rename_item(album_name,item_name,new_name)
    begin
      raise "album \"#{album_name}\" not found" unless Album.exists?(album_name)
      album = Album.get_by_name(album_name)
      raise "item \"#{item_name}\" not found" unless album.has_item?(item_name)
      raise "\"#{new_name}\" invalid name - use alphanumeric characters only" unless name_ok?(new_name)
      item = album.get_item_by_name(item_name)
      item.rename(new_name)
      raise "name is \"#{item.name}\"" unless item.name == new_name
      [0,"item \"#{item_name}\" renamed to \"#{new_name}\""]
    rescue => e
      [1,"rename_item \"#{item_name}\" failed: #{e}"]
    end
  end




end
