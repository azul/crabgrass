class Widget < ActiveRecord::Base

  debugger
  acts_as_tree :order => 'position'

  def partial
    file = self.class.name.underscore
    file.sub! /_widget$/, ''
    "widgets/#{file}"
  end

end
