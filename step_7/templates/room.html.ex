<!DOCTYPE html>
<html ng-app="mainApp">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A Fancy Page</title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/js/jquery.min.js"></script>
    <script src="/js/bootstrap.min.js"></script>
    <script src="/js/angular.js"></script>
  </head>
  <body ng-controller="MainCtrl">
    <div class="navbar navbar-default">
      <div class="container-fluid">
        <div class="navbar-header">
          <a href="/rooms" class="navbar-brand">A Fancy Chat</a>
        </div> 
        <ul class="nav navbar-nav navbar-left" ng-hide="!!currentUser">
        <li><a href data-toggle="modal" data-target="#registrationModal">Create User Account</a></li>
        <div class="modal fade" id="registrationModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">Register for a User Account</h4>
              </div>
              <div class="modal-body">
                <div class="form-group">
                  <label>Enter a Username</label> 
                  <input class="form-control" type="text" ng-model="newUsername" />
                </div>
                <div class="form-group">
                  <label>Enter a Password</label> 
                  <input class="form-control" type="password" ng-model="newPassword" />
                </div>
                <div class="form-group">
                  <label>Please, Re-enter the same password</label> 
                  <input class="form-control" type="password" ng-model="newPasswordConf" />
                </div>
                <div class="alert alert-danger" ng-show="registrationError">
                  <p>The password and password confirmation do not match</p>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" ng-click="sendRegistration(newUsername, newPassword, newPasswordConf)">Save changes</button>
              </div>
            </div>
          </div>
        </div>
        </ul>
        <form class="navbar-form navbar-right" ng-show="!!currentUser">
          <a href="#">Signed in as: {{ currentUser }}</a>
          <button class="btn btn-default" ng-click="submitSignout()">Sign Out</button>
        </form>
        <form class="navbar-form navbar-right" ng-hide="!!currentUser">
          <div class="form-group">
            <input type="text" class="form-control" placeholder="Username" ng-model="username">
            <input type="password" class="form-control" placeholder="Password" ng-model="password">
          </div>
          <button type="submit" class="btn btn-default" ng-hide="!!currentUser" ng-click="submitSignin(username, password)">Sign In</button>
        </form>
      </div>
    </div>
    <div class="container">
      <div class="jumbotron" style="margin-top:50px;">
        <h3>Welcome to Chat Room: {{ roomName }}</h3>
        <div ng-hide="has_password || !currentUserIsOwner">
          <p>Add a Password</p>
          <div class="form-group">
            <input class="form-control" type="password" ng-model="password" />
            <br>
            <button ng-click="sendNewPassword(password)" class="btn btn-primary">Set Password</button>
          </div>
        </div>
        <div ng-show="has_password">
          <p>This chat room is password protected</p>
        </div>
        <hr>
        <div ng-show="currentUserIsOwner">
          <p ng-show="!!roomDescription">Chat Room Description: {{ roomDescription }}<p>
          <div ng-show="!roomDescription">
            <p>There is no room description. Add one: </p>
            <div class="form-group">
              <textarea class="form-control" rows="3" ng-model="newRoomDescription"></textarea><br>
              <button ng-click="sendNewRoomDescription(newRoomDescription)" class="btn btn-primary">Save</button>
            </div>
          </div>
        </div>
      </div>
      <a href="/rooms"><- Back to Rooms</a>
    </div>
    <script>
      app = angular.module("mainApp", []);

      app.factory("RoomData", function() {
        var roomName = "<%= @room_name %>";
        var roomDescription = "<%= @room_description %>";
        var passwordProtected = <%= @password_set %>;
        var currentUser = "<%= @current_user %>";
        var currentUserIsOwner = <%= @current_user_is_owner %>;

        return {
          getRoomName: function() {
            return roomName;
          },
          getRoomDescription: function() {
            return roomDescription;
          },
          showPassword: function() {
            return passwordProtected;
          },
          getCurrentUser: function() {
            if (currentUser == "") {
              return undefined;
            } else {
              return currentUser;
            }
          },
          getOwnershipStatus: function() {
            return currentUserIsOwner;
          }
        };
      });

      app.controller("MainCtrl", function($scope, $http, $q, RoomData) {
        var sendRoomUpdate = function(updateType, updateData) {
          var deferred = $q.defer();

          var requestUrl = "/rooms/" + $scope.roomName;

          $http({
            method: "POST",
            url: requestUrl,
            headers: {
              "Content-Type": "application/json"
            },
            data: [updateType, updateData]
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          })

          return deferred.promise;;
        };

        var sendCreateUserRequest = function(username, password, passwordConfirmation) {
          var deferred = $q.defer();

          $http({
            method: "POST",
            url: "/users",
            headers: {
              "Content-Type": "application/json"
            },
            data: [username, password, passwordConfirmation]
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          });

          return deferred.promise;
        };

        var sendCreateSessionRequest = function(username, password) {
          var deferred = $q.defer();

          $http({
            method: "POST",
            url: "/sessions",
            headers: {
              "Content-Type": "application/json"
            },
            data: [username, password]
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          });

          return deferred.promise;
        };

        var sendDeleteSessionRequest = function() {
          var deferred = $q.defer();

          $http({
            method: "DELETE",
            url: "/sessions",
            headers: {
              "Content-Type": "application/json"
            }
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          });
          
          return deferred.promise;
        };


        $scope.submissionError = false;

        $scope.roomName = RoomData.getRoomName();
        $scope.roomDescription = RoomData.getRoomDescription();
        $scope.has_password = RoomData.showPassword();
        $scope.currentUser = RoomData.getCurrentUser();
        $scope.currentUserIsOwner = RoomData.getOwnershipStatus();

        $scope.sendRegistration = function(username, password, passwordConfirmation) {
          if (password == passwordConfirmation) {
            sendCreateUserRequest(username, password, passwordConfirmation).then(function(status) {
              console.log("User created ", status);
              $scope.registrationError = false; 
              $scope.newUsername = "";
              $scope.newPassword = "";
              $scope.newPasswordConf = "";

              $scope.currentUser = username;

              $scope.submitSignin(username, password);
            }, function(status) {
              console.log("Failed to create new user ", status);
            });
          } else {
            $scope.registrationError = true;            
          }
        };

        $scope.submitSignin = function(username, password) {
          sendCreateSessionRequest(username, password).then(function(status) {
            $scope.username = "";
            $scope.password = "";

            $scope.currentUser = username;
            console.log("Successfully signed in ", status);
          }, function(status) {
            console.log("Unable to sign in ", status);
          });
        };

        $scope.submitSignout = function() {
          sendDeleteSessionRequest().then(function(status) {
            $scope.currentUser = undefined;
            console.log("Successfully logged out");
          }, function(status) {
            console.log("Unable to log out");
          });  
        };
        
        $scope.sendNewRoomDescription = function(roomDescription) {
          sendRoomUpdate("description", roomDescription).then(function(status) {
            $scope.submissionError = false;
            $scope.roomDescription = roomDescription;
          }, function(status) {
            $scope.submissionError = true;
          });
        };

        $scope.sendNewPassword = function(password) {
          sendRoomUpdate("password", password).then(function(status) {
            $scope.has_password = true;
            $scope.password = undefined;
          }, function(status) {
            $scope.has_password = false;
          });
        };
      });
    </script>
  </body>
</html>
