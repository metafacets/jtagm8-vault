require_relative 'tag'
require 'singleton'

class Facade
  attr_accessor :taxonomy, :album
  include Singleton

  def name_ok?(name) name =~ /^[A-Za-z0-9_]+$/ end

  def grammar(msg)
    # convert nouns from plural to singular form excluding 'n of m' groups
    # hyphonate adjectives to nouns eg. 5 folksonomy_tags
    msg.gsub!(/((?<!\sof\s)1\s)([a-zA-Z"][a-z_"]+)(ies)(\b)/,'\1\2y\4')
    msg.gsub!(/((?<!\sof\s)1\s)([a-zA-Z"][a-z_"]+)(s)(\b)/,'\1\2\4')
    msg.gsub!(/(.*)(_)(.*)/,'\1 \3')
    # convert 0 to no excluding 'n of m' groups
    msg.gsub!(/((?<!\sof\s)0\s(?!of\s))([a-zA-Z][a-z]+\b)/,'no \2')
    msg
  end

  def wipe
    begin
      Tagm8Db.wipe
      [0,'database wiped']
    rescue => e
      [1,"wipe failed: #{e}"]
    end
  end

  def add_taxonomy(taxonomy_name,dag='prevent')
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise "\"#{taxonomy_name}\" taken" if Taxonomy.exists?(taxonomy_name)
      raise "\"#{taxonomy_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(taxonomy_name)
      raise "dag \"#{dag}\" invalid - use prevent, fix or free" unless ['prevent','fix','free'].include?(dag)
      tax = Taxonomy.new(taxonomy_name,dag)
      raise "taxonomy \"#{taxonomy_name}\" remains non-existent" unless Taxonomy.exists?(taxonomy_name)
      raise 'taxonomy added, but dag not set' unless tax.dag == dag
      [0,"Taxonomy \"#{taxonomy_name}\" added"]
    rescue => e
      [1,"add_taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_taxonomies(taxonomy_list,details=false)
    begin
      taxonomy_list = 'nil:NilClass' if taxonomy_list.nil?
      raise 'taxonomy list missing' if taxonomy_list.empty? || taxonomy_list == 'nil:NilClass'
      list = taxonomy_list.gsub(/\s/,'').split(',')
      found = list&Taxonomy.list
      raise 'no listed taxonomies found' if found.empty?
      Taxonomy.delete_taxonomies(found)
      deleted = found-Taxonomy.list
      details_msg = ''
      unless deleted.empty?
        deleted.each{|name| details_msg += "taxonomy \"#{name}\" deleted\n"} if details
        found.size == deleted.size ? d_insert = ' and' : d_insert = ", #{deleted}"
      else
        d_insert = ' but none'
      end
      msg = grammar("#{found.size} of #{list.size} taxonomies \"#{taxonomy_list}\" found#{d_insert} deleted")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"delete_taxonomies \"#{taxonomy_list}\" failed: #{e}"]
    end
  end

  def rename_taxonomy(taxonomy_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise 'taxonomy rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'rename unchanged' if taxonomy_name == new_name
      raise "\"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      raise "\"#{new_name}\" taken" if Taxonomy.exists?(new_name)
      raise "\"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      tax.rename(new_name)
      raise "name is \"#{tax.name}\"" unless tax.name == new_name
      [0,"Taxonomy \"#{taxonomy_name}\" renamed to \"#{new_name}\""]
    rescue => e
      [1,"rename_taxonomy \"#{taxonomy_name}\" to \"#{new_name}\" failed: #{e}"]
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
      [0,grammar("#{c} taxonomies found")] + res
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
      tax.instantiate(tag_syntax,false)
      tags_added = (tax.list_tags-tags_before).sort.map{|name| "\"#{name}\""}
      d_insert = ''
      tags_added.each{|name| d_insert += "Tag \"#{name}\" added"} if details
      links_added = tax.count_links-links_before
      msg = grammar("#{tags_added.size} tags and #{links_added} links added to taxonomy \"#{taxonomy_name}\"")
      [0,"#{d_insert}#{msg}"]
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
      found == deleted ? insert = ' and' : insert = ", #{deleted}"
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
      raise "\"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
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
            roots = tax.roots.map{|tag| tag.name}.sort!
            roots.reverse! if reverse
            roots.each{|root_name| res += show_nested.call(tax,root_name,reverse)}
            msg = "#{roots_count} hierarchies found containing #{tags_count-folks_count} tags and #{tax.count_links} links\n"
          else
            msg = "No tag hierarchies found\n"
          end
          if folks_count > 0
            folks = tax.folksonomies.map{|tag| tag.name}.sort!
            folks.reverse! if reverse
            res += folks
            msg += "#{folks_count} folksonomy_tags found\n"
          else
            msg += "No folksonomy_tags found\n"
          end
        else
          res = tax.list_tags.sort!
          res.reverse! if reverse
          msg = ''
        end
        msg += "#{tags_count} tags found in total"
      else
        msg = "No tags found"
      end
      [0,"#{grammar(msg)} for taxonomy \"#{taxonomy_name}\""] + res
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
      list.size > 1 ? common = 'common_' : common = ''
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
      [0,grammar("#{res.size} #{common}#{genealogy} found")] + res
    rescue => e
      [1,"list_#{genealogy} failed: #{e}"]
    end
  end

  def add_album(taxonomy_name,album_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" taken by taxonomy \"#{taxonomy_name}\"" if tax.has_album?(album_name)
      raise "album \"#{album_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(album_name)
      tax.add_album(album_name)
      raise "album \"#{album_name}\" remains non-existent" unless Album.exists?(album_name)
#      raise "album \"#{album_name}\" created but not added to taxonomy #{taxonomy_name}" unless tax.has_album?(album_name)
      [0,"Album \"#{album_name}\" added to taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"add_album \"#{album_name}\" to taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_albums(taxonomy_name,album_list,details=false)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_list = 'nil:NilClass' if album_list.nil?
      raise 'album list missing' if album_list.empty? || album_list == 'nil:NilClass'
      list = album_list.gsub(/\s/,'').split(',')
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      found = tax.list_albums&list
      raise 'no listed albums found' if found.empty?
      tax.delete_albums(found)
      tax = Taxonomy.get_by_name(taxonomy_name) # refresh tax after delete_albums
      deleted = found-tax.list_albums
      details_msg = ''
      unless deleted.empty?
        deleted.each{|name| details_msg += "album \"#{name}\" deleted\n"} if details
        found.size == deleted.size ? d_insert = ' and' : d_insert = ", #{deleted}"
      else
        d_insert = ' but none'
      end
      msg = grammar("#{found.size} of #{list.size} albums \"#{album_list}\" found#{d_insert} deleted from taxonomy \"#{taxonomy_name}\"")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"delete_albums \"#{album_list}\" from taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def rename_album(taxonomy_name,album_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'album rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'album rename unchanged' if album_name == new_name
      raise "album \"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      raise "album \"#{new_name}\" taken by taxonomy \"#{taxonomy_name}\"" if tax.has_album?(new_name)
      renamed = Album.count_by_name(new_name)
      tax.get_album_by_name(album_name).rename(new_name)
      renamed = Album.count_by_name(new_name) - renamed
      raise "no albums renamed to \"#{new_name}\"" if renamed == 0
      [0,"Album renamed from \"#{album_name}\" to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"rename_album \"#{album_name}\" to \"#{new_name}\" in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def list_albums(taxonomy_name=nil,album_name=nil,reverse=false,details=false)
    begin
      raise 'taxonomy unspecified' if !taxonomy_name.nil? && taxonomy_name.empty?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
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
      album_total = "#{res.size} albums"
      unless res.empty?
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
          item_details = " containing #{item_total} items"
          in_taxonomy = " in #{taxonomies.size} taxonomies" if taxonomy_name.nil?
        end
      end
      [0,grammar("#{album_total}#{with_name} found#{in_taxonomy}#{item_details}")] + res
    rescue => e
      [1,"list_albums failed: #{e}"]
    end
  end

  def count_albums(taxonomy_name=nil,album_name=nil)
    begin
      raise 'taxonomy unspecified' if !taxonomy_name.nil? && taxonomy_name.empty?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      raise "Taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      taxonomy_name.nil? ? res = Album.count_by_name(album_name) : res = Taxonomy.get_by_name(taxonomy_name).count_albums(album_name)
      [0,'',res]
    rescue => e
      [1,"count_tags failed: #{e}"]
    end
  end

  def add_item(taxonomy_name,album_name,item)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      item = 'nil:NilClass' if item.nil?
      raise 'item unspecified' if item.empty? || item == 'nil:NilClass'
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      album = tax.get_album_by_name(album_name)
      item_name,*rest = item.split('\n')
      item_name.gsub!(/\s/,'')
      raise "item \"#{item_name}\" taken by album \"#{album_name}\" in taxonomy \"#{taxonomy_name}\"" if album.has_item?(item_name)
      raise "item \"#{item_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(item_name)
      items_added = Item.count
      item = album.add_item("#{item_name}\n"+rest.join("\n"))
      items_added = Item.count - items_added
      raise 'No items were added' if items_added == 0
      [0,"Item \"#{item.name}\" added to album \"#{album_name}\" in taxonomy \"#{taxonomy_name}\""]
    rescue => e
      [1,"add_item to album \"#{album_name}\" in taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def delete_items(taxonomy_name,album_name,item_list,details=false)
    # details could report on item_dependent tags that are deleted
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      album_name = 'nil:NilClass' if album_name.nil?
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      item_list = 'nil:NilClass' if item_list.nil?
      raise 'item list missing' if item_list.empty? || item_list == 'nil:NilClass'
      list = item_list.gsub(/\s/,'').split(',')
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      album = tax.get_album_by_name(album_name)
      found = album.list_items&list
      raise 'no listed items found' if found.empty?
      album.delete_items(found)
      deleted = found-album.list_items
      details_msg = ''
      unless deleted.empty?
        deleted.each{|name| details_msg += "item \"#{name}\" deleted\n"} if details
        found.size == deleted.size ? d_insert = ' and' : d_insert = ", #{deleted}"
      else
        d_insert = ' but none'
      end
      msg = grammar("#{found.size} of #{list.size} items \"#{item_list}\" found#{d_insert} deleted from album \"#{album_name}\" of taxonomy \"#{taxonomy_name}\"")
      [0,"#{details_msg}#{msg}"]
    rescue => e
      [1,"delete_items \"#{item_list}\" from album \"#{album_name}\" of taxonomy \"#{taxonomy_name}\" failed: #{e}"]
    end
  end

  def rename_item(taxonomy_name,album_name,item_name,new_name)
    begin
      taxonomy_name = 'nil:NilClass' if taxonomy_name.nil?
      album_name = 'nil:NilClass' if album_name.nil?
      location = "album \"#{album_name}\" of taxonomy \"#{taxonomy_name}\""
      raise 'taxonomy unspecified' if taxonomy_name.empty? || taxonomy_name == 'nil:NilClass'
      raise 'album unspecified' if album_name.empty? || album_name == 'nil:NilClass'
      item_name = 'nil:NilClass' if item_name.nil?
      raise 'item unspecified' if item_name.empty? || item_name == 'nil:NilClass'
      new_name = 'nil:NilClass' if new_name.nil?
      raise 'item rename unspecified' if new_name.empty? || new_name == 'nil:NilClass'
      raise 'item rename unchanged' if item_name == new_name
      raise "item \"#{new_name}\" invalid - use alphanumeric and _ characters only" unless name_ok?(new_name)
      raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
      tax = Taxonomy.get_by_name(taxonomy_name)
      raise "album \"#{album_name}\" not found in taxonomy \"#{taxonomy_name}\"" unless tax.has_album?(album_name)
      album = tax.get_album_by_name(album_name)
      raise "item \"#{item_name}\" not found in #{location}" unless album.has_item?(item_name)
      raise "item \"#{new_name}\" name taken by #{location}" if album.has_item?(new_name)
      item = album.get_item_by_name(item_name)
      item.rename(new_name)
      raise "name is \"#{item.name}\"" unless item.name == new_name
      [0,"Item renamed from \"#{item_name}\" to \"#{new_name}\" in #{location}"]
    rescue => e
      [1,"rename_item \"#{item_name}\" to \"#{new_name}\" in #{location} failed: #{e}"]
    end
  end

  def count_items(taxonomy_name=nil,album_name=nil,item_name=nil)
    begin
      what = ''
      what += " with name \"#{item_name}\"" unless item_name.nil?
      what += " in album \"#{album_name}\"" unless album_name.nil?
      what += " of taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      raise 'item unspecified' if !item_name.nil? && item_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        unless Album.exists?(album_name)
          raise 'no albums found' if album_name.nil?
          raise "album \"#{album_name}\" not found"
        end
        albums = Album.get_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        unless tax.has_album?(album_name)
          album_name.nil? ? msg = 'no albums' : msg = "album \"#{album_name}\" not"
          raise "#{msg} found in taxonomy \"#{taxonomy_name}\""
        end
        album_name.nil? ? albums = tax.albums : albums = [tax.get_album_by_name(album_name)]
      end
      res = albums.map{|album| album.count_items(item_name)}.inject(:+)
      [0,'',res]
    rescue => e
      [1,"count_items#{what} failed: #{e}"]
    end
  end

  def list_items(taxonomy_name=nil,album_name=nil,item_name=nil,reverse=false,details=false)
    begin
      what = ''
      what += " with name \"#{item_name}\"" unless item_name.nil?
      what += " in album \"#{album_name}\"" unless album_name.nil?
      what += " of taxonomy \"#{taxonomy_name}\"" unless taxonomy_name.nil?
      raise 'album unspecified' if !album_name.nil? && album_name.empty?
      raise 'item unspecified' if !item_name.nil? && item_name.empty?
      if taxonomy_name.nil?
        raise 'no taxonomies found' unless Taxonomy.exists?
        unless Album.exists?(album_name)
          raise 'no albums found' if album_name.nil?
          raise "album \"#{album_name}\" not found"
        end
        albums = Album.get_by_name(album_name)
      else
        raise 'taxonomy unspecified' if taxonomy_name.empty?
        raise "taxonomy \"#{taxonomy_name}\" not found" unless Taxonomy.exists?(taxonomy_name)
        tax = Taxonomy.get_by_name(taxonomy_name)
        unless tax.has_album?(album_name)
          album_name.nil? ? msg = 'no albums' : msg = "album \"#{album_name}\" not"
          raise "#{msg} found in taxonomy \"#{taxonomy_name}\""
        end
        album_name.nil? ? albums = tax.albums : albums = [tax.get_album_by_name(album_name)]
      end
      puts "Facade.list_items 1:"
      res = []
      puts "Facade.list_items 2: albums=#{albums}"
      albums.each do |album|
        puts "Facade.list_items 2a: album.list_items(item_name)=#{album.list_items(item_name)}"
        res += album.list_items(item_name)
      end
      item_count = res.size
      puts "Facade.list_items 3:"
      if item_name.nil?
        res.sort!
        res.reverse! if reverse
      end
      if details
        item_name.nil? ? itm_name_max_size = res.max_by(&:length).size : itm_name_max_size = item_name.size
        details,tax_name_max_size,alm_name_max_size,tag_count_max_size,i = [],0,0,0,0
        puts "Facade.list_items 4:"
        res.uniq.each do |item_name|
          albums.each do |album|
            if album.has_item?(item_name)
              tax_name,alm_name,tag_count = album.taxonomy.name,album.name,album.get_item_by_name(item_name).tags.size
              details[i] = [item_name,alm_name,tax_name,tag_count]
              tax_name_max_size = tax_name.size if tax_name.size > tax_name_max_size
              alm_name_max_size = alm_name.size if alm_name.size > alm_name_max_size
              tag_count_max_size = tag_count/10+1 if tag_count/10+1 > tag_count_max_size
              i += 1
            end
          end
        end
        res,i = [],0
        puts "Facade.list_items 5:"
        details.each do |detail|
          if i%10 > 0
            res[i] = "      %-#{itm_name_max_size}s            %-#{alm_name_max_size}s               %-#{tax_name_max_size}s      %#{tag_count_max_size}s     " % [detail[0],detail[1],detail[2],detail[3]]
          else
            res[i] = "item \"%-#{itm_name_max_size}s\" in album \"%-#{alm_name_max_size}s\" of taxonomy \"%-#{tax_name_max_size}s\" has %#{tag_count_max_size}s tags" % [detail[0],detail[1],detail[2],detail[3]]
          end
          i += 1
        end
      end
      [0,grammar("#{item_count} items found#{what}")]+res
    rescue => e
      [1,"list_items#{what} failed: #{e}"]
    end
  end

end

#f = Facade.instance
#puts "#{f.grammar('0 of 1 taxonomies found with 5 links and 3 tags in 1 albums and 1 taxonomies and 5 taxonomies and 0 items')}"
#puts "#{f.grammar('0 albums and 1 taxonomies in 0 of 1 taxonomies and 0 items')}"
