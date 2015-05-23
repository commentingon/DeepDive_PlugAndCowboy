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

        return {
          getRooms: function() {
            return rooms;
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

        $scope.angular_status = "Angular is Working!";
        $scope.rooms = RoomsData.getRooms();

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
