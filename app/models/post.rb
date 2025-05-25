class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  
  has_many :taggings           # ✅ Add this line
  has_many :tags, through: :taggings
  
  validates :tags, presence: true
end
