class Array
  def batchSave
    return if self.length == 0
    self.first.class.transaction do
      self.each do |resource|
        resource.save
      end
    end
  end
end