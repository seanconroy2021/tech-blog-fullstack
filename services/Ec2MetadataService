const axios = require('axios');
// made with the use of Github Co-Pilot
class Ec2MetadataService {
  constructor() {
    this.metadataBaseUrl = 'http://169.254.169.254/latest/meta-data/';
    this.tokenUrl = 'http://169.254.169.254/latest/api/token';
  }

  async getImdsv2Token() {
    try {
      const response = await axios.put(this.tokenUrl, '', {
        headers: {
          'X-aws-ec2-metadata-token-ttl-seconds': '21600', // 6 hours
        },
      });
      return response.data; // The token
    } catch (error) {
      console.error("Error fetching IMDSv2 token:", error);
      throw new Error("Can't get");
    }
  }

  async fetchMetadata(metadataPath) {
    try {
      const token = await this.getImdsv2Token();
      const response = await axios.get(`${this.metadataBaseUrl}${metadataPath}`, {
        headers: {
          'X-aws-ec2-metadata-token': token,
        },
      });
      return response.data;
    } catch (error) {
      return "Error fetching metadata"
    }
  }
}
module.exports = new Ec2MetadataService();
