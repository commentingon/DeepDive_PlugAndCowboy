<!DOCTYPE html>
<html ng-app="mainApp">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A Fancy Page</title>
    <link rel="icon" href="http://sstatic.net/so/favicon.ico" />
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
                <button type="button" class="btn btn-primary" ng-click="sendRegistration(newUsername, newPassword, newPasswordConf)">Create Account</button>
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
        <h1>Restful Chat Rooms</h1>
        <p>{{ angular_status }}</p>
      </div>
      <div class="row">
        <div class="col-xs-6">
          <h3>Post request from Form</h3>
          <br>
          <form action="/rooms" method="POST">
            <label>Create a Chat Room</label></br>
            <input type="text" name="roomName" />
            <input type="submit" class="btn btn-primary" />
          </form>
        </div>
        <div class="col-xs-6">
          <h3>Post request via JSON</h3>
          <br>
          <label>Create a Chat Room</label></br>
          <input type="text" ng-model="roomName" />
          <button ng-click="createRoom(roomName)" class="btn btn-primary">Submit</button>
        </div>
      </div>
      <hr>
      <div class="row">
        <div class="col-xs-12">
          <h3>Choose a Chat Room to Join</h3>
        </div>
      </div>
      <br>
      <div id="rooms_list" class="row">
          <div class="col-xs-3"  ng-repeat="room in rooms">
            <div class="panel panel-default">
              <div class="panel-heading">
                Room Name: {{ room }}
              </div>
              <div class="panel-body">
                <a ng-click="deleteRoom(room)" href>Delete</a> 
                <a href="/rooms/{{ room }}"><button class="btn btn-primary pull-right">Join Chat</button></a>
              </div>
            </div>
          </div>
      </div>

    </div>
    <script>
      app = angular.module("mainApp", []);

      app.factory("RoomsData", function() {
        var rooms = <%=  inspect @rooms %>;
        var current_user = "<%= @current_user %>";

        return {
          getRooms: function() {
            return rooms;
          },
          getCurrentUser: function() {
            if (current_user == "") {
              return undefined;
            } else {
              return current_user;
            }
          }
        };
      });

      app.controller("MainCtrl", function($scope, $http, $q, RoomsData) {
        var sendDeleteRequest = function(name) {
          var deferred = $q.defer();

          var requestUrl = "/rooms/" + name;

          $http({
            method: "DELETE",
            url: requestUrl
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          });

          return deferred.promise;
        };

        var sendPostRequest = function(name) {
          var deferred = $q.defer();

          $http({
            method: "POST",
            url: "/rooms",
            headers: {
              "Content-Type": "application/json"
            },
            data: name
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          });

          return deferred.promise;
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

        $scope.angular_status = "Angular is Working!";
        $scope.rooms = RoomsData.getRooms();
        
        $scope.currentUser = RoomsData.getCurrentUser();
        $scope.registrationError = false;  

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

        $scope.createRoom = function(name) {
          sendPostRequest(name).then(function(status) {
            var lowercaseName = angular.lowercase(name);
            $scope.rooms.push(lowercaseName);

            $scope.roomName = "";
          }, function(status) {
            console.log("Failure: ", status);
          });
        };

        $scope.deleteRoom = function(name) {
          sendDeleteRequest(name).then(function(status) {
            var roomIndex = $scope.rooms.indexOf(name);
            $scope.rooms.splice(roomIndex, 1);
          }, function(status) {
            console.log("Unable to delete element ", status);
          });
        };
      });
    </script>
  </body>
</html>
