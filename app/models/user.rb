class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :rememberable, :trackable
  devise :database_authenticatable, :registerable, :recoverable, :validatable
end
