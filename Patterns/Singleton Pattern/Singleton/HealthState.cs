using System;
using System.Collections.Generic;
using System.Text;

namespace Singleton
{
    class HealthState
    {
        private static HealthState healthState;
        private static readonly Object syncLock = new Object();

        private List<string> Errors { get; set; } = new List<string>();
        private List<int> Results { get; set; } = new List<int>();
        private int Done { get; set; } = 0;
        private int Total { get; set; } = 0;

        public void TaskFinished(int res)
        {
            lock(syncLock)
            {
                Total++;
                Done++;
                Results.Add(res);
            }
        }

        public void TaskFailed(string msg)
        {
            lock (syncLock)
            {
                Total++;
                Errors.Add(msg);
            }
        }

        public string GetTextReport()
        {
            return $"Executed: {Total}, \r\nTask failed: {Total - Done},\r\nresults: {String.Join(',', Results)}";
        }

        public static HealthState GetInstance()
        {
            if (healthState == null)
            {
                lock(syncLock)
                {
                    healthState = new HealthState();
                }
            }

            return healthState;
        }
    }
}
