class Widget < ActiveRecord::Base

  acts_as_tree :order => 'position'

  def partial
    file = self.class.name.underscore
    file.sub! /_widget$/, ''
    "widgets/#{file}"
  end

  def edit_partial
    file = self.class.name.underscore
    file.sub! /_widget$/, ''
    "widgets/#{file}/edit"
  end

end
