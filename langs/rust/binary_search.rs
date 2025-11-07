fn binarySearch(nums: &[i32], target: i32) -> i32 {
    // max 10^9 for each num and max 10^6 nums
    // use isize, handles ~2 billion
    // and won't wrap on low - 1 when low == 0
    let mut left: isize = 0;
    let mut right: isize = nums.len() as isize - 1;
    let mut i: isize;

    while left <= right {
        i = left + (right - left) / 2;
        if nums[i as usize] < target {
            left = i + 1;
        } else if nums[i as usize] > target {
            right = i - 1;
        } else {
            return i as i32;
        }
    }
    return -1;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_binary_search() {
        let nums = [1, 3, 5, 7, 9];
        assert_eq!(binarySearch(&nums, 1), 0);
        assert_eq!(binarySearch(&nums, 5), 2);
        assert_eq!(binarySearch(&nums, 9), 4);
        assert_eq!(binarySearch(&nums, 2), -1);
        assert_eq!(binarySearch(&nums, 10), -1);
        assert_eq!(binarySearch(&nums[0..0], 42), -1);
        assert_eq!(binarySearch(&nums[0..1], 42), -1);
        assert_eq!(binarySearch(&nums[0..1], 1), 0);
        assert_eq!(binarySearch(&nums[0..2], 3), 1);
    }
}
