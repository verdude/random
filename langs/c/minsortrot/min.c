int find_min(int* nums, int nums_size) {
  return 0;
}

int find_min(int* nums, int nums_size, int pos) {
  if (nums[pos + 1] < nums[pos]) {
    return nums[pos + 1];
  }

  if (nums[pos - 1] > nums[pos]) {
    return nums[pos];
  }
}
