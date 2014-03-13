class ActiveSupport::Cache::MemoryStore
  def keys
    @data.keys
  end

  def values
    @data.values.map(&:value)
  end
end
