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
    <div class="container">
      <div class="jumbotron" style="margin-top:50px;">
        <h3>Welcome to Chat Room: {{ roomName }}</h3>
        <p ng-show="!!roomDescription">Chat Room Description: {{ roomDescription }}<p>
        <div ng-show="!roomDescription">
          <p>There is no room description. Add one: </p>
          <div class="form-group">
            <textarea class="form-control" rows="3" ng-model="newRoomDescription"></textarea><br>
            <button ng-click="sendNewRoomDescription(newRoomDescription)" class="btn btn-primary">Save</button>
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

        return {
          getRoomName: function() {
            return roomName;
          },
          getRoomDescription: function() {
            return roomDescription;
          }
        };
      });

      app.controller("MainCtrl", function($scope, $http, $q, RoomData) {
        var sendRoomDescription = function(roomDescription) {
          var deferred = $q.defer();

          var requestUrl = "/rooms/" + $scope.roomName;

          $http({
            method: "POST",
            url: requestUrl,
            headers: {
              "Content-Type": "application/json"
            },
            data: roomDescription
          })
          .success(function(data, status, headers) {
            deferred.resolve(status);
          })
          .error(function(data, status, headers) {
            deferred.reject(status);
          })

          return deferred.promise;;
        };

        $scope.submissionError = false;

        $scope.roomName = RoomData.getRoomName();
        $scope.roomDescription = RoomData.getRoomDescription();
        
        $scope.sendNewRoomDescription = function(roomDescription) {
          sendRoomDescription(roomDescription).then(function(status) {
            $scope.submissionError = false;
            $scope.roomDescription = roomDescription;
          }, function(status) {
            $scope.submissionError = true;
        });
        };
      });
    </script>
  </body>
</html>
