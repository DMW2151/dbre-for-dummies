# Database Reliability Exercises

I just finished Charity Major's & Laine Campbell's [Database Reliablity Engineering](https://www.oreilly.com/library/view/database-reliability-engineering/9781491925935/) and it gave me a few ideas for short exercises in maintaining database systems.

- **Running Production Datastores on Ephemeral Disk** - Stemmed from an anecdote about how Pinterest used EC2 instance's ephemeral storage to get lower latency on production databases.

> In 2013, Pinterest moved their MySQL database instances to run on ephemeral storage in Amazon Web Services (AWS). Ephemeral storage effectively means that if the compute instance fails or is shut down, anything stored on disk is lost. Pinterest chose the ephemeral storage option because of consistent throughput and low latency...Ephemeral storage did not allow snapshots, which meant that the restore approach was full database copies over the network rather than attaching a snapshot in preparation for rolling forward of the transaction logs. This shows that you can maintain data safety in ephemeral environments with the right processes and the right tools!
