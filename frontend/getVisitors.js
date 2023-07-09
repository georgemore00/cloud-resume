const URL = "https://ookxrbexlb.execute-api.us-east-1.amazonaws.com/prod/visitors"

document.addEventListener('DOMContentLoaded', () => {
  axios.get(URL)
    .then(response => {
      const data = response.data;
      const visitorsString = data;
      const visitors = parseInt(visitorsString.split(":")[1]);
      console.log(visitors);

      const visitorCountElement = document.getElementById('visitor-count');
      visitorCountElement.textContent = visitors; // Update the visitor count

    })
    .catch(error => console.log(error));
});
