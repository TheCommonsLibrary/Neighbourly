class User
  def initialize(db)
    @user_table = db[:users]
  end

  def create!(user_details)
    HTTParty.post(ENV["ZAP_API"],:body => user_details)
    fields = @user_table.columns.map(&:to_s)
    user = fields.each_with_object(Hash.new) {|key, hash| hash[key.to_sym] = user_details[key] }
    @user_table.insert(user.merge(created_at: Time.now.utc))
  end

  def where(*cond, &block)
    @user_table.where(*cond, &block)
  end
end
