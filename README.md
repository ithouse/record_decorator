
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'record_decorator'
```

## Supported versions ##

* Rails 3.2.x, 4, 5.0

## Supported ORMs ##

ActiveRecord

If Your ORM is not supported be aware codebase is very small.
It works like this:

```
@user = User.find(5)
@user.extend User::AddOns::VeryNice
```
Where
  @user may be the model or another instance of ruby object
  User::AddOns::VeryNice is module

## Usage

Simple case

```
#model
class User < ActiveRecord::Base
end

# Default decorator
# Any decorator uses AR model scope
module User::AddOns::Decorator
  def email
    "Email: #{super}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

# controller must call decorator
class UsersController < ApplicationController
  def index
    @users = Users.all.page(params[:page]).decorate
  end

  def show
    @user = User.find(params[:id]).decorate
  end
end
```

Context specific decorators
```
#model
class User < ActiveRecord::Base
end

# Default decorator
module User::AddOns::Decorator
  def full_name
    "#{first_name} #{last_name}"
  end
end

module User::AddOns::Show
  include User::AddOns::Decorator

  def full_position
    "#{profile.position}, #{profile.branch}, #{profile.city}"
  end
end

module User::AddOns::Step1
  # add validation for this step
  def self.extended base
    base.singleton_class.validates :first_name, :last_name, presence: true
  end

  # add processing method for this step
  def process(params, analytic)
    result = update(permitted_params(params))
    if result
      # on success do something
      analytic.track({user: self, event: 'fill_name'})
    end
    result
  end

  private

  def permitted_params(params)
    params.require(:user).permit(:first_name, :last_name)
  end
end


# controller must call decorator
class UsersController < ApplicationController
  def index
    @users = Users.all.page(params[:page]).decorate
  end

  def show
    @user = User.find(params[:id]).decorate(:show)
  end

  def create_step1
    @user = User.find(params[:id]).decorate(:step1)
    # method defined in the decorator Step1
    @user.process(params, @analytic)
  end
end
```


## Contributing


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Inspired By

https://github.com/itkrt2y/active_decorator
