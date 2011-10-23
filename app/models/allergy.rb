class Allergy < ActiveRecord::Base
  has_many :users_allergies
  has_many :users, :through => :users_allergies 
  has_many :specifics, :class_name => "Allergy", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Allergy"

  validates_presence_of :name
  validates_uniqueness_of :name

  
  ########################################################### 
  ## Returns suballergies associated with the self allergy
  ## Usage: a= Allergy.find_by_name("soy")
  ## => a.suballergies  
  ## Can then be used to look up record details such as .id, .name
   
  def suballergies
    suballergies = Allergy.find(:all, :conditions => {:parent_id => self.id}).map {|x| 
        if !x.nil? 
          x
        end}
  end
  
  ###########################################################
  ## Returns suballergies associated with the self allergy, returns names
  ## Usage: Allergy.suballergies_names
  
  def suballergies_names
    suballergies = Allergy.find(:all, :conditions => {:parent_id => self.id}).map {|x| 
      if !x.nil? 
        x.name
      end}
  end
  
  ##################
  # Class methods
  ##################
  
  def self.get_displayed_allergy_names
    Allergy.find(:all, :conditions => {:display => "yes", :parent_id => nil}).map {|a| a.name}
  end
  
  def self.get_parent_allergies
    Allergy.find(:all, :conditions => {:parent_id => nil})
  end

  def self.get_parent_allergy_names
    Allergy.find(:all, :conditions => {:parent_id => nil}).map {|a| a.name}
  end
end


