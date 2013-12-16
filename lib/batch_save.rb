class Array
  def batchSave
    self.first.class.transaction do
      self.each do |resource|
        resource.save
      end
    end
  end
end