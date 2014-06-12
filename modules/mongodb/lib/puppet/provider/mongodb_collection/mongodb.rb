require 'puppet/provider/mongodb'

Puppet::Type.type(:mongodb_collection).provide :mongodb, :parent => Puppet::Provider::Mongodb do

  desc "Manages MongoDB collections."

  defaultfor :kernel => 'Linux'

  def create
    mongo_command("db.createCollection('#{@resource[:name]}')", @resource[:router], @resource[:database])
  end

  def destroy
    raise Puppet::Error, 'Not implemented'
  end

  def exists?
    block_until_command
    collection_names = db_collections(@resource[:database], @resource[:router])
    collection_names.include?(@resource[:name])
  end

  def shard_enabled
    issharded = sh_issharded(@resource[:name], @resource[:database], @resource[:router])
    issharded ? :true : :false
  end

  def shard_enabled=(value)
    if :true == value
      sh_shard(@resource[:name], @resource[:database], @resource[:shard_key], @resource[:router])
    else
      raise Puppet::Error, "Cannot disable sharding for collection `#{@resource[:name]}`"
    end
  end

  private

  def sh_shard(collection, dbname, key, master)
    output = mongo_command_json("sh.shardCollection(\"#{dbname}.#{collection}\", {'#{key}': 1})", master)
    if output['ok'] == 0
      raise Puppet::Error, "sh.shardCollection() failed for #{dbname}.#{collection}: #{output['errmsg']}"
    end
  end

  def sh_status(collection, dbname, master)
    mongo_command_json("db.getMongo().getDB('#{dbname}').getCollection('#{collection}').stats()", master)
  end

  def sh_issharded(collection, dbname, master)
    sh_status(collection, dbname, master)['sharded']
  end

end
