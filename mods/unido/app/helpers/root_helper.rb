module RootHelper
  def add_a_job_opportunity
    link_to_with_icon 'wrench', 'Add a job opportunity'[:add_job_page],
      {:controller => :wiki_page,
        :action => :create,
        :id => :wiki,
        :group => current_site.network,
        :page => {:summary => "Location: (please fill out)\nDescription: (please fill out)",
          :title => "Job Opportunity: (please fill out)",
          :tag_list => "job, jobs, jobsearch, employment"}
    }
  end
end
