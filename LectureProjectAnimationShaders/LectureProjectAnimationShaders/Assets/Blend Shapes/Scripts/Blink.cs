using UnityEngine;

public class Blink : MonoBehaviour
{
    Animator _animator; // The animator component of the object
                        // Start is called once before the first execution of Update after the MonoBehaviour is created

    float _randomInterval;
    float _timer = 0.0f;
    void Start()
    {
        _animator = GetComponent<Animator>(); // Get the animator component
        _randomInterval = Random.Range(1.0f, 3.0f);
    }

    // Update is called once per frame
    void Update()
    {
        _timer += Time.deltaTime; // Increment the timer by the time since the last frame

        if (_timer >= _randomInterval) // If the timer is greater than or equal to the random interval
        {

            _animator.SetTrigger("Blink"); // Set the trigger to start the blink animation
            _randomInterval = Random.Range(1.0f, 3.0f); // Set a new random interval between 1 and 3 seconds
            _timer = 0.0f; // Reset the timer
        }

    }
}
// Pseudo code for blend shape animation
