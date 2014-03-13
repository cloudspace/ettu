class User < Struct.new(:user)
  cattr_reader :instance
  @@instance = User.new(:test)

  def cache_key
    user
  end

  def updated_at
    @time ||= Time.now.to_i
  end
end
