// Complete the electionWinner function below.
function electionWinner(votes) {
    let candidateList = [];
    
    function updateCandidateList(array, value) {
    for (var i = 0; i < array.length; i++) {
        if (array[i]['name'] === value) {
            array[i].votes++
            return array;
        }
    } 
    array.push({name: value, votes: 1});
    return array;
    }
    
    votes.forEach(function(vote) {
        if(candidateList.length == 0) {
            candidateList.push({name: vote, votes: 1})
        } else {
            candidateList = updateCandidateList(candidateList, vote);
        }
    });

    function sortListByVotes(arr) {
       var switched;
       do {
           switched = false;
           for (var i=0; i < arr.length-1; i++) {
               if (arr[i]['votes'] > arr[i+1]['votes']) {
                   var temp = arr[i];
                   arr[i] = arr[i+1];
                   arr[i+1] = temp;
                   switched = true;
               }
           }
       } while (switched);
       console.log("sorted list", arr);

       return arr;
   }
   
   let sortedList = sortListByVotes(candidateList);
    
    var heighestVote = sortedList[sortedList.length-1].votes;
    
    function getHighestVotes(arr, numberOfVotes) {
        let newArr = [];
        for (var i=0; i < arr.length; i++) {
            console.log("numberOfVotes", numberOfVotes);
           if (arr[i]['votes'] === numberOfVotes) {
               newArr.push(arr[i].name);
           }
       }
        console.log("newArr", newArr);
        return newArr;
    }
    
    let listOfWinners = getHighestVotes(sortedList, heighestVote);
    
    listOfWinners = listOfWinners.sort();
    
    let winner = listOfWinners[listOfWinners.length-1];
    
    return winner;
}

